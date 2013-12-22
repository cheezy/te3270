
guard :rspec, :all_on_start => true, :cmd => 'rspec --color --format Fuubar' do
  watch(%r{^spec/*/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

