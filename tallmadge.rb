class Tallmadge < Formula
  desc "CLI manager for ~/.agents/ and AI coding harness extensions"
  homepage "https://github.com/kplawver/tallmadge"
  url "https://github.com/kplawver/tallmadge/archive/refs/tags/0.1.0.tar.gz"
  sha256 "b27a39ff9c7063b65072b9dc6d533f48445dcf9d54f01746c1e8f25282695598"
  license "MIT"

  depends_on "ruby"
  uses_from_macos "git"

  resource "rainbow" do
    url "https://rubygems.org/downloads/rainbow-3.1.1.gem"
    sha256 "039491aa3a89f42efa1d6dec2fc4e62ede96eb6acd95e52f1ad581182b79bc6a"
  end

  resource "thor" do
    url "https://rubygems.org/downloads/thor-1.5.0.gem"
    sha256 "e3a9e55fe857e44859ce104a84675ab6e8cd59c650a49106a05f55f136425e73"
  end

  def install
    ENV["GEM_HOME"] = libexec

    resources.each do |r|
      r.verify_download_integrity(r.fetch)
      system "gem", "install", r.cached_download,
             "--no-document",
             "--ignore-dependencies",
             "--install-dir", libexec
    end

    system "gem", "build", "tallmadge.gemspec"
    system "gem", "install", "tallmadge-#{version}.gem",
           "--no-document",
           "--ignore-dependencies",
           "--install-dir", libexec

    bin.install libexec/"bin/clpr"
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
  end

  test do
    assert_match "clpr #{version}", shell_output("#{bin}/clpr version")
  end
end
