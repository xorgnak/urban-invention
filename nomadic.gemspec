Gem::Specification.new do |spec|
  spec.name = "nomadic"
  spec.version = "0.4.2"
  spec.authors = ["E. Leonard"]
  spec.email = ["xorgnak@gmail.com"]

  spec.summary = "The nomadic tools via rubygem for raspberry pi."
  spec.homepage = "https://github.com/xorgnak/nomadic"
  spec.license = "MIT"

  spec.metadata = {
    "source_code_uri" => spec.homepage,
    "homepage_uri" => spec.homepage,
    "bug_tracker_uri" => spec.homepage + "/issues",
    "changelog_uri" => spec.homepage + "/releases"
  }

  spec.files = Dir.glob(%w[LICENSE.txt README.md {bin,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "bin"
  spec.executables = ["nomadic"]
  spec.require_paths = ["lib"]
end
