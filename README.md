# AndFeathers

Declaratively and iteratively build in-memory archive structures.

## Installation

Add this line to your application's Gemfile:

    gem 'and_feathers'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install and_feathers

## Usage

The examples below focus on specifying an archive's structure using `and_feathers`. See:

* [`and_feathers-gzipped_tarball`](https://github.com/bcobb/and_feathers-gzipped_tarball) for notes on writing a `.tgz` file to disk
* [`and_feathers-zip`](https://github.com/bcobb/and_feathers-zip) for notes on writing a `.zip` file to disk

Once you're "inside" `and_feathers`, either because you've called `AndFeathers.build` or `AndFeathers.from_path`, the two main methods you'll call on block parameters are `file` and `dir`. These, as you might suspect, create file and directory entries, respectively.

The examples below show how you might use these two methods to build up directory structures.

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

In the example below, we load the fixture directory at [`spec/fixtures/archiveme`](/spec/fixtures/archiveme), and then use `and_feathers` to perform surgery on the in-memory archive. In particular, we add a `test` directory and file to its archive, and update its `lib` directory a couple of times.

```ruby
require 'and_feathers'

archive = AndFeathers.from_path('spec/fixtures/archiveme')
archive.file('test/basic_test.rb') { '# TODO: tests' }
archive.file('lib/archiveme/version.rb') do
  "module Archiveme\n  VERSION = '1.0.0'\nend"
end
archive.file('lib/archiveme.rb') do
  # The Archiveme fixture is a class, but we'll change it to a module
  "module Archiveme\nend"
end
```
