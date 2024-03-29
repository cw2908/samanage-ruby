# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"


rspec_options = {
  cmd: "bundle exec rspec",
  all_on_start: true,
  run_all: {
    cmd: "bundle exec parallel_rspec -o '",
    cmd_additional_args: "--format RspecJunitFormatter --out /tmp/junit.xml --format documentation'",
  },
}


guard :rspec, rspec_options do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/samanage_#{m[1]}_spec.rb" }
  watch(%r{^lib/api/(.+)\.rb$})     { |m| "spec/lib/api/samanage_#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})
  watch("spec/spec_helper.rb")  { "spec" }
end
