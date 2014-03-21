# AndFeathers

Declaratively build in-memory archive structures. Use with [`and_feathers-gzipped_tarball`](https://github.com/bcobb/and_feathers-gzipped_tarball) and/or [`and_feathers-zip`](https://github.com/bcobb/and_feathers-zip) to generate artifacts.

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
require 'and_feathers/gzipped_tarball'
require 'and_feathers/zip'
require 'json'

tarball = AndFeathers.build('redis') do |redis|
  redis.file('README.md') { "README content" }
  redis.file('metadata.json') { JSON.dump({}) }
  redis.file('metadata.rb') { "# metadata.rb content" }
  redis.dir('attributes') do |attributes|
    attributes.file('default.rb') { '# default.rb content' }
  end
  redis.dir('recipes') do |recipes|
    recipes.file('default.rb') { '# default.rb content' }
  end
  redis.dir('templates') do |templates|
    templates.dir('default')
  end
end

tarball.to_io(AndFeathers::GzippedTarball) # a gzipped, tarball StringIO
tarball.to_io(AndFeathers::Zip) # a zipped StringIO
```


