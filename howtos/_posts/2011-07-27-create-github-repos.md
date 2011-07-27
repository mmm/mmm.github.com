---
layout: post
title: Create new repos using the github api
tags: ["howto"]
---

Ok, I'm too lazy to go through the web interface every time I want to add a new github repo.
github api to the rescue...

Grab your API Token from your github account, "Account Settings" -- "Account Admin".

Use curl

    curl -u "mmm/token:XXXXXXXX" https://github.com/api/v2/json/user/show/mmm | jsonpretty

    curl -X POST -u "mmm/token:XXXXXXXX" https://github.com/api/v2/json/repos/create -d "name=junk2&description=morejunk2"

or the same thing using restclient (`sudo gem install rest-client`):

    restclient get https://github.com/api/v2/json/user/show/mmm mmm token:XXXXXXXX | jsonpretty 

    echo '{"name":"junk3","description":"junk3 description"}' | restclient post https://github.com/api/v2/json/repos/create mmm token:XXXXXXXX


Github docs say you should send at least `name` but it will take any of these as POST args:

 - `name` => name of the repository. ex: "my-repo" or "other-user/my-repo" 
 - `description` => repo description 
 - `homepage` => homepage url 
 - `public` => 1 for public, 0 for private

so I'll use a script...

    #!/usr/bin/ruby

    require 'rubygems'
    require 'json'
    require 'rest-client'

    USER = "mmm"
    TOKEN = "747241b1282480a88c0bd1241175c291"
    URL = "https://github.com/api/v2/json/repos/create"

    def usage 
      puts <<-EOS
        usage: #{$0} <name> [<description>] [<homepage>] [<public>]
        where:
          name => name of the repository
          description => repo description
          homepage => homepage url
          public => 1 for public, 0 for private
      EOS
      exit 1
    end
    ARGV.size > 0 || usage

    params = {
      "login" => USER,
      "token" => TOKEN,
      "name" => ARGV[0],
      "description" => ARGV[1] || "",
      "homepage" => ARGV[2] || "",
      "public" => ARGV[3] || "1",
    }

    puts "creating repo: #{params.to_json}"

    response = RestClient.post URL, params

    puts response.body


I'll call it `git-create` and put it in my path at `~/bin`.
Notice that git even picks it up as a builtin so I can

    git create myrepo "my repo description"

and shit just works.

