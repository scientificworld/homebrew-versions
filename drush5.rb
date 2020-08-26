class Drush5 < Formula
  homepage "https://github.com/drush-ops/drush"
  url "http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz"
  sha256 "3acc2a2491fef987c17e85122f7d3cd0bc99cefd1bc70891ec3a1c4fd51dccee"

  bottle :unneeded

  keg_only "Conflicts with drush in main repository."

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec+"drush"
  end
end
