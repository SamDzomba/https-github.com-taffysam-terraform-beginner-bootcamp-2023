## Terraform Bootcamp Week2 Update

## Working with Ruby

## Bundler 
- Bundler is a package manager for Ruby
- It is the primary way to install ruby packages


### Install Gems
- You need to create gemfiles a gems in that file.

An example of the Gemfile:

```rb
#### frozen_string_literal: true

source "https://rubygems.org"

gem 'sinatra'
gem 'rake'
gem 'pry'
gem 'puma'
gem 'activerecord'

```  

Then you need to run the `bundle install` command. This will install the gems on the system globally.

The Gemfile.lock will be created to lock down the gem versions being used.

### Executing Ruby Scritpts in the context of bundler

We have to use `bundler exec` to tell future ruby scripts to use the gems we installed. This is a way to set context.

## Sinatra
- Is a web micro-web framwork for Ruby to build web apps. 
- It good for mock or Dev servers or small projects.
- You can create web server in a single file.

Its accessed on

https://www.sinatrarb.com/

## Terratowns Mock Server

### Running the web Server

- We can run the web server by running the following commands: 

```rb
bundle exec ruby server.rb
bundle install

```

All the code for our server is stored in the `server.rb` file.








