gem 'i18n', '>= 0.5'

if respond_to? :fake_gem
  fake_gem 'mongodb'
  fake_gem 'file_model'
  fake_gem 'validatable2'
  fake_gem 'ruby_ext'
end