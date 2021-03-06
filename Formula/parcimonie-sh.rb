class ParcimonieSh < Formula
  desc "Refresh your GnuPG keyring discreetly"
  homepage "https://github.com/EtiennePerot/parcimonie.sh"
  url "https://github.com/EtiennePerot/parcimonie.sh.git",
      :revision => "4016b027274294787562be1900920e3834bc69bb"
  version "0.0.0.1" # Fake version to allow easier updates.
  version_scheme 1

  head "https://github.com/EtiennePerot/parcimonie.sh.git"

  depends_on "gnupg2" => :recommended
  depends_on "homebrew/versions/gnupg21" => :optional
  depends_on "torsocks" => :recommended
  depends_on "tor" => :optional

  def install
    inreplace "parcimonie.sh" do |s|
      s.gsub! "${TORSOCKS_BINARY:-torsocks}", "${TORSOCKS_BINARY:-#{Formula["torsocks"].opt_bin}/torsocks}"

      if build.with? "gnupg21"
        s.gsub! "${GNUPG_BINARY:-gpg}", "${GNUPG_BINARY:-#{Formula["gnupg21"].opt_bin}/gpg2}"
      else
        s.gsub! "${GNUPG_BINARY:-gpg}", "${GNUPG_BINARY:-#{Formula["gnupg2"].opt_bin}/gpg}"
      end
    end

    (var/"parcimonie").mkpath
    bin.install "parcimonie.sh" => "parcimonie"
  end

  def caveats; <<-EOS.undent
    Tor must be running for parcimonie to work.
  EOS
  end

  plist_options :manual => "parcimonie"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
            <string>/bin/sh</string>
            <string>-c</string>
            <string>#{opt_bin}/parcimonie</string>
        </array>
        <key>StandardErrorPath</key>
        <string>#{var}/parcimonie/keyupdate.err</string>
        <key>StandardOutPath</key>
        <string>#{var}/parcimonie/keyupdate.out</string>
      </dict>
    </plist>
    EOS
  end
end
