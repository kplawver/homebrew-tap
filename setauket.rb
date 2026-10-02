class Setauket < Formula
  desc "Local cross-harness context storage for coding agents"
  homepage "https://github.com/kplawver/setauket"
  url "https://github.com/kplawver/setauket/archive/refs/tags/v0.7.2.tar.gz"
  sha256 "7176a403e86ed23fd281c07f9cef03895858162872acbb5704d488c97b3c1854"
  license "MIT"

  depends_on "llama.cpp"
  depends_on "python@3.12"
  depends_on "uv"

  def install
    libexec.install "pyproject.toml", "uv.lock", "src"
    # Install native wheels after Homebrew's binary relocation pass; upstream
    # wheel dylib headers do not have the padding Homebrew needs to rewrite IDs.
    (bin/"setauket").write <<~SH
      #!/bin/sh
      exec "#{opt_libexec}/.venv/bin/setauket" "$@"
    SH
    chmod 0755, bin/"setauket"
  end

  post_install_steps do
    run "{{HOMEBREW_PREFIX}}/opt/uv/bin/uv",
        args: ["sync", "--locked", "--no-dev", "--no-editable", "--no-python-downloads",
               "--python", "{{HOMEBREW_PREFIX}}/opt/python@3.12/bin/python3.12"],
        chdir: "{{libexec}}", writable_paths: ["{{libexec}}"], network_access: true,
        env: { "UV_CACHE_DIR" => "{{libexec}}/uv-cache" }
    remove "uv-cache", base: :libexec, recursive: true
  end

  service do
    run [opt_bin/"setauket", "serve"]
    environment_variables PATH: "#{formula_opt_bin("llama.cpp")}:#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin"
    keep_alive true
    log_path var/"log/setauket.log"
    error_log_path var/"log/setauket.err.log"
  end

  test do
    assert_match "usage: setauket", shell_output("#{bin}/setauket --help")
  end
end
