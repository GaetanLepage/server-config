{pkgs, ...}: let
  domain = "invidious.glepage.com";
  port = 3000;
in {
  services = {
    caddy.virtualHosts."${domain}".extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';

    invidious = {
      enable = true;

      # package = pkgs.invidious.overrideAttrs (oldAttrs: {
      #   version = "unstable-CUSTOM";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "iv-org";
      #     repo = "invidious";
      #     fetchSubmodules = true;
      #     rev = "9ce9c543992243737516750bf08f5d073e899715";
      #     hash = "sha256-yyNtMvHaN3hNxTafhQivN39NzEylrm+FG7S5DNkCtWU=";
      #   };
      # });

      inherit domain;
      inherit port;

      settings = {
        # Allow/Forbid Invidious (local) account creation.
        # Invidious accounts allow users to subscribe to channels and to create playlists
        # without a Google account.
        registration_enabled = false;

        # It is now mandatory to set the hmac key (used for CSRF tokens and pubsub subscriptions
        # verification.)
        # https://github.com/iv-org/invidious/issues/3854
        hmac_key = "ef9Shohh6hucuaK5thae";

        # Enable/Disable the "Popular" tab on the main page
        popular_enabled = false;

        db.user = "invidious";

        default_user_preferences = {
          # List of feeds available on the home page.
          #
          # Note: "Subscriptions" and "Playlists" are only visible when the user is logged in.
          #
          # Accepted values: A list of strings
          # Each entry can be one of: "Popular", "Trending", "Subscriptions", "Playlists"
          #
          # Default: ["Popular", "Trending", "Subscriptions", "Playlists"]  (show all feeds)
          #
          feed_menu = ["Trending"];

          # Default feed to display on the home page.
          #
          # Note: setting this option to "Popular" has no effect when 'popular_enabled' is set
          # to false.
          #
          # Accepted values: Popular, Trending, Subscriptions, Playlists, <none>
          # Default: Popular
          #
          default_home = "Trending";

          # Default number of results to display per page.
          #
          # Note: this affects invidious-generated pages only, such as watch history and
          # subscription feeds.
          # Playlists, search results and channel videos depend on the data returned by the
          # Youtube API. (Default: 40)
          #
          max_results = 100;

          # Automatically play videos on page load. (Default: false)
          autoplay = false;
        };
      };
    };
  };
}
