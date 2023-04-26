cask "gitob" do

  version "1.0.0"

  arch arm: "arm64", intel: "amd64"

  on_arm do
    sha256 "3d216eeaf3c4cd2b44ea3de0ab1086aa97c2e586323535b65a5bea89b3fe2e79"
  end
  on_intel do
    sha256 "66a0a563933427035a6c66a7f61fd974a007a3a5524fab5cefe54628fe114e4d"
  end

  url "https://storage.googleapis.com/gitob-binary-files-production/pkg/#{version}/gitob_macos_#{arch}.zip"

  name = "gitob"
  desc = "Gitob is a CLI tool that helps teams onboard by using Git hooks."
  homepage = "https://gitob.getchinwag.com"

  # by default, homebrew-cask installs apps in the /Applications folder
  # but we want to install the binary in /usr/local/bin
  # so we use the `binary` stanza to specify the location of the binary
  # and create a symlink in /usr/local/bin pointing to the installed binary
  #
  # if the binary is installed using root permissions (sudo), we need to use
  # a privileged installer, which is triggered by the `sudo` parameter in the stanza
  # this will prompt the user for their password
  #
  # note: we assume the binary archive is a zip file
  # if it is a different type, you will need to modify the appropriate stanza
  #
  # we also automatically update the binary by checking the remote JSON file
  # and downloading the binary archive if a new version is available

  livecheck do
    url "https://storage.googleapis.com/gitob-binary-files-production/pkg/latest/release.json"
    regex(/"version"\s*:\s*"(\d+(?:\.\d+)*)"/i)
  end

  auto_updates = true

  binary "gitob"

  postflight do
      set_permissions "#{staged_path}/gitob", "0755"

      puts <<~EOS
        Congratulations! Gitob has been successfully installed.

        If you haven't already signed in please run the following command:

          gitob signin --access-code <access_code>

        This will finish the installation process and allow you to start your onboarding.

        For further information and documentation, please visit the Gitob website at:

          https://gitob.getchinwag.com

        Thank you for installing Gitob!

      EOS
  end

  uninstall do
    preflight do
      if File.exist?("$(brew --prefix)/bin/gitob")
        # this makes sure hooks are uninstalled properly
        system_command "$(brew --prefix)/bin/gitob", args: ['uninstall'], sudo: true
      end
    end
  end

end
