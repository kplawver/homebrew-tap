class Clothesline < Formula
  desc "Durable local messaging between coding agents"
  homepage "https://github.com/kplawver/clothesline"
  url "https://github.com/kplawver/clothesline/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "e5f6283edb374ff46702ec08b688c9a6e6eb6596aee74bdc0ce35c5dd31d502f"
  license "MIT"

  depends_on "python@3.12"
  depends_on "uv"

  def install
    libexec.install "pyproject.toml", "uv.lock", "src"
    # Install native wheels after Homebrew's binary relocation pass; upstream
    # wheel dylib headers do not have the padding Homebrew needs to rewrite IDs.
    (bin/"clothesline").write <<~SH
      #!/bin/sh
      exec "#{opt_libexec}/.venv/bin/clothesline" "$@"
    SH
    chmod 0755, bin/"clothesline"
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
    run [opt_bin/"clothesline", "serve"]
    environment_variables PATH: "#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin"
    keep_alive true
    log_path var/"log/clothesline.log"
    error_log_path var/"log/clothesline.err.log"
  end

  test do
    assert_match "usage: clothesline", shell_output("#{bin}/clothesline --help")
  end
end
