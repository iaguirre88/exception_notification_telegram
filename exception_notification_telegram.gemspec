
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "exception_notification_telegram/version"

Gem::Specification.new do |spec|
  spec.name          = "exception_notification_telegram"
  spec.version       = ExceptionNotificationTelegram::VERSION
  spec.authors       = ["Ignacio Aguirrezabal"]
  spec.email         = ["zirion0@gmail.com"]

  spec.summary       = "Telegram notifier for exception notification gem"
  spec.homepage      = "https://github.com/iaguirre88/exception_notification_telegram"
  spec.license       = "MIT"

  spec.required_ruby_version = '~> 2.4'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.8"

  spec.add_dependency "exception_notification", "~> 4.4"
  spec.add_dependency "httparty", "~> 0.13.2"
end
