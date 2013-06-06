---
layout: post
title: send basecamp message
categories: howtos
comments: true
---

This was cobbled together from other stuff... no longer have the links

    require 'net/https'

    class BasecampMessage

      #curl -H 'Accept: application/xml' -H 'Content-Type: application/xml' \
      #     -u hoodlum:up2n0g00d \
      #     -d '<todo-item><content>...</content></todo-item>' \
      #     http://url/todo_lists/123/todo_items.xml

      #https://agiledynamics.basecamphq.com/projects/<project_id>/posts

      # this works
      # curl -H 'Accept: application/xml' -H 'Content-Type: application/xml' -u <user>:<pass> https://agiledynamics.basecamphq.com/projects/<project_id>/posts

      #<request>
      #  <post>
      #    <category-id>#{category_id}</category-id>
      #    <title>#{title}</title>
      #    <body>#{body}</body>
      #    <private>1</private> <!-- only for firm employees -->
      #  </post>
      #  <notify>#{person_id}</notify>
      #  <notify>#{person_id}</notify>
      #  ...
      #  <attachments>
      #    <name>#{name}</name> <!-- optional -->
      #    <file>
      #      <file>#{temp_id}</file> <!-- the id of the previously uploaded file -->
      #      <content-type>#{content_type}</content-type>
      #      <original_filename>#{original_filename}</original-filename>
      #    </file>
      #  </attachments>
      #  <attachments>...</attachments>
      #  ...
      #</request>

      BASECAMP_SETTINGS = {
        :subdomain  => 'XXX',
        :username   => 'XXX',
        :password   => 'XXX',
        :ssl        => true
      }

      def self.update_message( environment, release, revision )

        http = Net::HTTP.new("#{BASECAMP_SETTINGS[:subdomain]}.basecamphq.com", BASECAMP_SETTINGS[:ssl] ? 443 : 80)

        # if using ssl, then set it up
        if BASECAMP_SETTINGS[:ssl]
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        begin
          request = Net::HTTP::Post.new("/projects/<project_id>/posts.xml?formatted=true", {'Content-type' => 'application/xml'})
          request.basic_auth BASECAMP_SETTINGS[:username], BASECAMP_SETTINGS[:password]
          request.body = "<post><title>What's on #{environment.to_s.capitalize}?</title><body>Changeset [sw:#{revision}] deployed on #{DateTime.parse(release)} (UTC).  You can see the [History for #{environment.to_s.capitalize}] (/projects/<project_id>/repositories/<repo_id>/history/#{environment.to_s}/ \"History for #{environment.to_s.capitalize}\").</body></post>"

          response = http.request(request)
          if response.code == "201"
            puts "Message Created: #{response['Location']}"
          else
            # hmmm...we must have done something wrong
            puts "HTTP Status Code: #{response.code}."
          end
        rescue => e
          puts "exception: #{e.to_s}"
          print e.backtrace
        end

      end
      
    end

