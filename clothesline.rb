class Clothesline < Formula
  desc "Local shared memory for coding agents"
  homepage "https://github.com/kplawver/clothesline"
  url "https://github.com/kplawver/clothesline/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "b32c40058edb2e58e3d2adfa74583d63a1b99fafa6f0730d1e790e4e1fa76a73"
  license "MIT"

  depends_on "llama.cpp"
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
    environment_variables PATH: "#{formula_opt_bin("llama.cpp")}:#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin"
    keep_alive true
    log_path var/"log/clothesline.log"
    error_log_path var/"log/clothesline.err.log"
  end

  test do
    assert_match "usage: clothesline", shell_output("#{bin}/clothesline --help")
  end
end
