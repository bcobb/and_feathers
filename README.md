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

### Writing a file from an archive's `StringIO`

```ruby
require 'and_feathers'
require 'and_feathers/zip'
require 'and_feathers/gzipped_tarball'

# This is a simple archive
archive = AndFeathers.build('archive') do |root|
  root.file('README')
end

File.open('archive.tgz', 'w+') do |f|
  f << archive.to_io(AndFeathers::Zip).read
end

# or

File.open('archive.zip', 'w+') do |f|
  f << archive.to_io(AndFeathers::GzippedTarball).read
end
```

### Specify each directory and file individually

```ruby
require 'and_feathers'
require 'json'

archive = AndFeathers.build('redis') do |redis|
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
```

### Specify directories and files by their paths

```ruby
require 'and_feathers'

archive = AndFeathers.build('rails_app') do |app|
  app.file('README.md') { "README content" }
  app.file('config/routes.rb') do
    "root to: 'public#home'"
  end
  app.dir('app/controllers') do |controllers|
    controllers.file('application_controller.rb') do
      "class ApplicationController < ActionController:Base\nend"
    end
    controllers.file('public_controller.rb') do
      "class PublicController < ActionController:Base\nend"
    end
  end
  app.file('app/views/public/home.html.erb')
end
```

### Load an existing directory as an Archive

In the example below, we load the fixture directory at [`spec/fixtures/archiveme`](/tree/master/spec/fixtures/archiveme), add a `test` directory and file to its archive, and update its `lib` directory a couple of times.

```ruby
require 'and_feathers'

archive = AndFeathers.from_path('spec/fixtures/archiveme')
archive.file('test/basic_test.rb') { '# TODO: tests' }
archive.file('lib/archiveme/version.rb') do
  "module Archiveme\n  VERSION = '1.0.0'\nend"
end
archive.file('lib/archiveme.rb') do
  # The Archiveme fixture is a class, so we'll change it to a module
  "module Archiveme\nend"
end
```
