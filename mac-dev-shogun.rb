class MacDevShogun < Formula
  desc "Ultimate macOS bootstrapping for AI + Crypto Engineers"
  homepage "https://github.com/shijien/mac-dev-shogun"
  url "https://github.com/shijien/mac-dev-shogun/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "f26ab1366ab63baa68484da66e2ca2447d051dddd83c59162d36fce67de46338"
  license "MIT"

  depends_on "zsh"
  depends_on "git"
  depends_on "node"
  depends_on "rust"
  depends_on "python"

  def install
    bin.install "setup_dev_env.sh"
    bin.install "setup_ai_crypto_tooling.sh"
    bin.install "setup_vscode.sh"

    (bin/"mac-dev-shogun").write <<~EOS
      #!/bin/bash
      case "$1" in
        dev)      bash #{bin}/setup_dev_env.sh ;;
        tooling)  bash #{bin}/setup_ai_crypto_tooling.sh ;;
        vscode)   bash #{bin}/setup_vscode.sh ;;
        *) echo "Usage: mac-dev-shogun {dev|tooling|vscode}" ;;
      esac
    EOS
  end
end
