# AndFeathers

Declaratively build in-memory gzipped tarballs.

## Installation

Either run:

    $ gem install and_feathers

Or, if you're using Bundler, add this line to your application's Gemfile:

    gem 'and_feathers'

And then execute:

    $ bundle

## Usage

Suppose you want to create the equivalent of a Chef cookbook artifact created using knife:

```ruby
require 'and_feathers'
require 'json'

tarball = AndFeathers.build('redis') do |redis|
  redis.file('README.md') { "README content" }
  redis.file('metadata.json') { JSON.dump({}) }
  redis.file('metadata.rb') { "# metadata.rb content" }
  redis.dir('attributes') do |attributes|
    attributes.file('default.rb') { '# default.rb content' }
  end
  redis.dir('recipes') do |recipes|
    attributes.file('default.rb') { '# default.rb content' }
  end
  redis.dir('templates') do |templates|
    templates.dir('default')
  end
end

tarball.to_io # a gzipped, tarball StringIO
```

