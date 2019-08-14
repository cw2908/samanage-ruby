# frozen_string_literal: true


require "samanage"
require "csv"
require "parallel"
require "json"

# Update date reference file
# This file saves the last date the script ran as YYYY-MM-DD
@date_ref = "samanage_date_pointer.json"
@current_date = Date.today
def check_reference
  @max_timestamp_from_prev = DateTime.parse(JSON.parse(File.read(@date_ref)).dig("max_timestamp"))
rescue ArgumentError, TypeError, Errno::ENOENT => e
  puts "Will create reference file"
  @max_timestamp_from_prev = false
end

token = ARGV[0]
if ARGV[1]
  PROCESSES = ARGV[1].to_i
else
  PROCESSES = 15
end
@samanage = Samanage::Api.new(token: token, max_retries: 3)
DEFAULT_FILENAME = "Incidents-#{DateTime.now.strftime("%b-%d-%Y")}.csv"
check_reference()

def log_to_csv(row:, filename: DEFAULT_FILENAME, headers:)
  write_headers = !File.exist?(filename)
  CSV.open(filename, "a+", write_headers: write_headers, headers: headers, force_quotes: true) do |csv|
    csv << row
  end
end




def get_incident_origin(incident_id)
  origin_map = {
    1 => "Web",
    2 => "Portal",
    3 => "API",
    4 => "Email"
  }
  origin = @samanage.execute(path: "incidents/#{incident_id}.json", verbose: true).to_h.dig(:data, "origin")
  origin_map[origin] || origin
end

def save_incidents
  if @max_timestamp_from_prev
    date_difference = (@current_date - @max_timestamp_from_prev.to_date).to_i
    # puts "date_difference: #{date_difference}"
    updated = case date_difference
              when 0 then 1
              when 1..6 then 7
              when 7..30 then 30
              when 30..60 then 60
              when 30..60 then 60
              when 60..90 then 90
              else nil
    end
    puts "Saving incidents created in the last #{date_difference + 1} days: #{updated.inspect}"
    options = {
      verbose: true,
      per_page: 25,
      sort_by: "updated_at",
      sort_order: "ASC",
    }
    options["updated[]"] = updated if !updated.nil?
  else
    puts "Saving all incidents"
    options = {
      verbose: true,
      sort_by: "updated_at",
      sort_order: "ASC",
      per_page: 25
    }
  end
  initial_request = @samanage.get_incidents(options: options)

  total_pages = initial_request[:total_pages]
  1.upto(total_pages).each_slice(PROCESSES) do |pages|
    Parallel.map(pages, in_processes: 4) do |page|
      # Check specific page
      puts "\n~~~~~~> Checking #{page.inspect}/#{total_pages.inspect}"
      paginated_option = options.merge(page: page)
      begin
        paginated_incidents = @samanage.get_incidents(options: paginated_option)[:data]
      rescue Errno::ENOENT, EOFError, Errno::ECONNRESET => e
        puts "Rescuing from EOF error"
        retry
      end
      # Go to the next page if updated_at is newer than the reference file
      max_timestamp_from_page = DateTime.parse(paginated_incidents.max_by { |incident| DateTime.parse(incident["updated_at"]) }.dig("updated_at"))
      if @max_timestamp_from_prev && @max_timestamp_from_prev > max_timestamp_from_page
        puts "Page ##{page} Incidents have been saved"
        next
      end
      Parallel.each(paginated_incidents, in_processes: PROCESSES) do |incident|
        incident_id = incident.dig("id")
        transform_data(incident_id)
        check_reference
        no_reference = !File.exist?(@date_ref)
        begin
          incident_newer_than_reference = DateTime.parse(incident.dig("updated_at")) > @max_timestamp_from_prev
        rescue ArgumentError, TypeError => e
          puts "[#{e.class}] #{e.inspect} will update date reference"
          incident_newer_than_reference = true
        end
        # Update reference
        if no_reference || incident_newer_than_reference
          @max_timestamp_from_prev = max_timestamp_from_page
          updated_ref = {
            incident_id: incident_id,
            max_timestamp: max_timestamp_from_page.to_s
          }
          puts "Updating: #{updated_ref}"
          file = File.open(@date_ref, "w+")
          file.write(JSON.pretty_generate(updated_ref))
          file.close
        end
      end
    end
  end
end

def find_custom_field(custom_fields_values, field_name, user_type = false)
  result = custom_fields_values.select { |field| field["name"] == field_name }.first.to_h
  if user_type
    result_value =  result.dig("user", "name") || result.dig("user", "email")
  else
    result_value =  result.dig("value")
  end
  return if [-1, "-1", nil, "", {}].include?(result_value)
  result_value
end

def find_name_from_group_id(group_id)
  return if [-1, "-1", nil, ""].include?(group_id)
  begin
    @samanage.find_group(id: group_id).to_h.dig(:data, "name")
  rescue
    return "Unable to find user for group id #{group_id}"
  end
end

def set_ticket_age(incident:)
  created_at = DateTime.parse(incident.dig("created_at"))
  # Check if ticket is still active
  if ["closed", "resolved"].include?(incident.dig("state").downcase)
    updated_at = DateTime.parse(incident.dig("updated_at"))
  else
    updated_at = DateTime.now
  end
  ticket_age = ((updated_at - created_at).to_f * 24).round(2)
  ticket_age.to_s
end

def transform_data(incident_id)
  incident = @samanage.find_incident(id: incident_id, options: { audit_archive: true, layout: "long" })[:data]
  puts "Saving Incident #{incident.dig('number')} - last modified #{incident.dig('updated_at')}"
  custom_fields_values = incident.dig("custom_fields_values").to_a
  audits = incident.dig("audits").to_a.concat(incident.dig("audit_archives").to_a)
  output_hash = {
    "Actual Production Date" => find_custom_field(custom_fields_values, "Actual Production Date"),
    "Age of Ticket (hours)" => set_ticket_age(incident: incident),
    "Application Affected - Legacy Zendesk" => find_custom_field(custom_fields_values, "Application Affected - Legacy Zendesk"),
    "Application Category" => find_custom_field(custom_fields_values, "Application Category"),
    "Application Impacted" => find_custom_field(custom_fields_values, "Application Impacted"),
    "Approval Status" => find_custom_field(custom_fields_values, "Approval Status"),
    "Area Impacted/LOB" => find_custom_field(custom_fields_values, "Area Impacted/LOB"),
    "Asset" => incident.dig("assets"),
    "Assigned To" => incident.dig("assignee", "name"),
    "Associated Sla Names" => incident.dig("associated_sla_names"),
    # 'Attachments links' => incident.dig('attachments'),
    "Best number to be reached at:" => find_custom_field(custom_fields_values, "Best number to be reached at:"),
    "Bill Type" => find_custom_field(custom_fields_values, "Bill Type"),
    "Broker Code" => find_custom_field(custom_fields_values, "Broker Code"),
    "Business Analyst" => find_name_from_group_id(find_custom_field(custom_fields_values, "Business Analyst")),
    "Business Application" => find_custom_field(custom_fields_values, "Business Application"),
    "Category" => incident.dig("category", "name"),
    "Changes" => incident.dig("changes"),
    "Closed At" => incident.dig("statistics").select { |s| s["statistic_type"] == "to_close" }.first.to_h.dig("value"),
    "Created At" => incident.dig("created_at"),
    "Created by" => incident.dig("created_by", "name"),
    "Customer Satisfaction Feedback" => incident.dig("customer_satisfaction_response"),
    "Customer Satisfied?" => incident.dig("is_customer_satisfied"),
    "Database Instance Name" => find_custom_field(custom_fields_values, "Database Instance Name"),
    "Department" => incident.dig("department", "name"),
    "Describe any relevant and expected downstream impact" => find_custom_field(custom_fields_values, "Describe any relevant and expected downstream impact"),
    "Desktop Support Category" => find_custom_field(custom_fields_values, "Desktop Support Category"),
    "Developer" => find_name_from_group_id(find_custom_field(custom_fields_values, "Developer")),
    "Direct Contact" => find_name_from_group_id(find_custom_field(custom_fields_values, "Direct Contact")),
    "Due Date" => incident.dig("due_at"),
    "Environment Type" => find_custom_field(custom_fields_values, "Environment Type"),
    "External Requester Email Address" => find_custom_field(custom_fields_values, "External Requester Email Address"),
    "External Requester Name" => find_custom_field(custom_fields_values, "External Requester Name"),
    "Hardware ids" => incident.dig("configuration_items").map { |ci| ci["id"] },
    "Hardware Issue" => find_custom_field(custom_fields_values, "Hardware Issue"),
    "Have you received new equipment in the last 30 days?" => find_custom_field(custom_fields_values, "Have you received new equipment in the last 30 days?"),
    "If Other, Please Name Here" => find_custom_field(custom_fields_values, "If Other, Please Name Here"),
    "Impact" => find_custom_field(custom_fields_values, "Impact"),
    "Implementation Status" => find_custom_field(custom_fields_values, "Implementation Status"),
    "Incident Category" => find_custom_field(custom_fields_values, "Incident Category"),
    "incident ids" => incident.dig("incidents").to_a.map { |i| i["id"] },
    "Incident Origin" =>  get_incident_origin(incident_id),
    "Is downtime necessary?" => find_custom_field(custom_fields_values, "Is downtime necessary?"),
    "JIRA Ticket Number" => find_custom_field(custom_fields_values, "JIRA Ticket Number"),
    "Legacy ZD D2C Website or Product" => find_custom_field(custom_fields_values, "Legacy ZD D2C Website or Product"),
    "Legacy Zendesk Assignee" => find_custom_field(custom_fields_values, "Legacy Zendesk Assignee"),
    "Legacy Zendesk Collaborators" => find_custom_field(custom_fields_values, "Legacy Zendesk Collaborators"),
    "Legacy Zendesk Department" => find_custom_field(custom_fields_values, "Legacy Zendesk Department"),
    "Legacy Zendesk Group" => find_custom_field(custom_fields_values, "Legacy Zendesk Group"),
    "Legacy Zendesk ID" => find_custom_field(custom_fields_values, "Legacy Zendesk ID"),
    "Legacy Zendesk Last Updated Date/Time" => find_custom_field(custom_fields_values, "Legacy Zendesk Last Updated Date/Time"),
    "Legacy Zendesk Requester" => find_custom_field(custom_fields_values, "Legacy Zendesk Requester"),
    "Legacy Zendesk Ticket Created Date/Time" => find_custom_field(custom_fields_values, "Legacy Zendesk Ticket Created Date/Time"),
    "Legacy Zendesk Ticket Priority" => find_custom_field(custom_fields_values, "Legacy Zendesk Ticket Priority"),
    "Legacy Zendesk Ticket Solved Date/Time" => find_custom_field(custom_fields_values, "Legacy Zendesk Ticket Solved Date/Time"),
    "Legacy Zendesk Ticket Type" => find_custom_field(custom_fields_values, "Legacy Zendesk Ticket Type"),
    "LOB" => find_custom_field(custom_fields_values, "LOB"),
    "Network Issue" => find_custom_field(custom_fields_values, "Network Issue"),
    "New Desk Phone Needed" => find_custom_field(custom_fields_values, "New Desk Phone Needed"),
    "Number" => incident.dig("number"),
    "Other Asset ids" => incident.dig("other_assets").to_a.map { |asset| asset["id"] },
    "Pending Approval" => find_custom_field(custom_fields_values, "Pending Approval"),
    "Phone (Cell)" => find_custom_field(custom_fields_values, "Phone (Cell)"),
    "Phone Country Code" => find_custom_field(custom_fields_values, "Phone Country Code"),
    "Phone (Office)" => find_custom_field(custom_fields_values, "Phone (Office)"),
    "Planned Deployment Date" => find_custom_field(custom_fields_values, "Planned Deployment Date"),
    "Planned End Time" => find_custom_field(custom_fields_values, "Planned Deployment Duration"),
    "Planned Deployment Start Time" => find_custom_field(custom_fields_values, "Planned Deployment Start Time"),
    "Please Submit New Requests Here:" => find_custom_field(custom_fields_values, "Please Submit New Requests Here:"),
    "Policyholder Name" => find_custom_field(custom_fields_values, "Policyholder Name"),
    "Policy/Product Instance Number(Put N/A if not needed)" => find_custom_field(custom_fields_values, "Policy/Product Instance Number(Put N/A if not needed)"),
    "Premiere Development Status" => find_custom_field(custom_fields_values, "Premiere Development Status"),
    "Premiere Request Type" => find_custom_field(custom_fields_values, "Premiere Request Type"),
    "Premiere Issue Category" => find_custom_field(custom_fields_values, "Premiere Issue Category"),
    "Price" => incident.dig("price"),
    "Primary Vendor" => find_custom_field(custom_fields_values, "Primary Vendor"),
    "Priority" => incident.dig("priority"),
    "Problem" => incident.dig("problem", "number"),
    "Premiere Program" => find_custom_field(custom_fields_values, "Premiere Program"),
    "Reference Number" => find_custom_field(custom_fields_values, "Reference Number"),
    "Reference Type" => find_custom_field(custom_fields_values, "Reference Type"),
    "Release Urgency" => find_custom_field(custom_fields_values, "Release Urgency"),
    "Request Approved" => find_custom_field(custom_fields_values, "Request Approved"),
    "Requester" => incident.dig("requester", "name"),
    "Request Variables" => incident.dig("request_variables"),
    "Resolution" => incident.dig("resolution"),
    "Resolution Code" => incident.dig("resolution_type"),
    "Resolved At" => incident.dig("statistics").select { |s| s["statistic_type"] == "to_resolve" }.first.to_h.dig("value"),
    "Resolved By" => audits.select { |audit| audit["message"].match(/to '​Resolved​'.$/) }.first.to_h.dig("user", "name"),
    "Risk Level" => find_custom_field(custom_fields_values, "Risk Level"),
    "Root Cause" => find_custom_field(custom_fields_values, "Root Cause"),
    # 'Scheduled' => ,
    "Security Incident Type" => find_custom_field(custom_fields_values, "Security Incident Type"),
    "Service Time To Assignment" => incident.dig("statistics").to_a.select { |s| s["statistic_type"] == "Incident Reassigned" }.first.to_h.dig("business_time_elapsed"),
    "Service Time To Closure" => incident.dig("statistics").to_a.select { |s| s["statistic_type"] == "to_close" }.first.to_h.dig("business_time_elapsed"),
    "Site" => incident.dig("site", "name"),
    "SLM Breaches" => incident.dig("sla_violations"),
    "Solution ids" => incident.dig("solutions").to_a.map { |i| i["id"] },
    "SSIS Package or Process" => find_custom_field(custom_fields_values, "SSIS Package or Process"),
    "State" => incident.dig("state"),
    "Steps to recreate issue" => find_custom_field(custom_fields_values, "Steps to recreate issue"),
    "Subcategory" => incident.dig("subcategory", "name"),
    "System Function" => find_custom_field(custom_fields_values, "System Function"),
    "Tags" => incident.dig("tags").map { |t| t["name"] },
    "Target Production Date" => find_custom_field(custom_fields_values, "Target Production Date"),
    "Team - Premiere Policy Reject" => find_custom_field(custom_fields_values, "Team - Premiere Policy Reject"),
    "Technician - IR Access Cloned from" => find_custom_field(custom_fields_values, "Technician - IR Access Cloned from", true),
    "Technician - IR Drawers" => find_custom_field(custom_fields_values, "Technician - IR Drawers"),
    "Technician - IR Folders" => find_custom_field(custom_fields_values, "Technician - IR Folders"),
    "Technician - IR Groups" => find_custom_field(custom_fields_values, "Technician - IR Groups"),
    "Technician - IR Workflow" => find_custom_field(custom_fields_values, "Technician - IR Workflow"),
    "Title" => incident.dig("name"),
    "To Assignment" => incident.dig("statistics").to_a.select { |s| s["statistic_type"] == "to_assignment" }.first.to_h.dig("time_elapsed"),
    "To Closure" => incident.dig("statistics").to_a.select { |s| s["statistic_type"] == "to_close" }.first.to_h.dig("time_elapsed"),
    "To First Response (Business)" => incident.dig("statistics").to_a.select { |s| s["statistic_type"] == "to_first_response" }.first.to_h.dig("business_time_elapsed"),
    "To First Response (Elapsed)" => incident.dig("statistics").to_a.select { |s| s["statistic_type"] == "to_first_response" }.first.to_h.dig("time_elapsed"),
    "Topic" => find_custom_field(custom_fields_values, "Topic"),
    "To Resolution (Business)" => incident.dig("statistics").to_a.select { |s| s["statistic_type"] == "to_resolve" }.first.to_h.dig("business_time_elapsed"),
    "To Resolution (Elapsed)" => incident.dig("statistics").to_a.select { |s| s["statistic_type"] == "to_resolve" }.first.to_h.dig("time_elapsed"),
    "Total Time Spent" => incident.dig("total_time_spent"),
    "Updated At" => incident.dig("updated_at"),
    "Vendor Ticket Number" => find_custom_field(custom_fields_values, "Vendor Ticket Number"),
    "What can we help you with?" => find_custom_field(custom_fields_values, "What can we help you with?"),
    "Who will implement/deploy the change?" => find_custom_field(custom_fields_values, "Who will implement/deploy the change?"),
    "Report DateTime" => DateTime.now
  }
  log_to_csv(row: output_hash.values, headers: output_hash.keys)
end

save_incidents()

puts "Complete"
