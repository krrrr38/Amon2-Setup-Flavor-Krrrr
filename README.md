This is Perl module Amon2::Setup::Flavor::Krrrr.

INSTALLATION

Amon2::Setup::Flavor::Krrrr installation is straightforward.

Download it, unpack it, then build it as per the usual:

    % git clone https://github.com/krrrr38/Amon2-Setup-Flavor-Krrrr.git
    % cd Amon2-Setup-Flavor-Krrrr
    % perl Makefile.PL
    % make && make test

Then install it:

    % make install

- using Amon2::Web::Dispatcher::RouterBoom
- using Teng as ORM
- not using javascript library
  - to use angular, remove jquery dependency
- using Test::Class for test with t::Util
- when using parameters(query parameter, body parameter or path parameter)

```
my $value  = $c->string_param('key');
my @values = $c->number_param('key');
```

generated files

```
├── Build.PL
├── config
│   ├── development.pl
│   ├── production.pl
│   └── test.pl
├── cpanfile
├── db
│   └── schema.sql
├── lib
│   ├── MyApp
│   │   ├── DB
│   │   │   ├── Row
│   │   │   │   ├── Entry.pm
│   │   │   │   └── User.pm
│   │   │   ├── Row.pm
│   │   │   └── Schema.pm
│   │   ├── DB.pm
│   │   ├── UserAgent.pm
│   │   ├── Web
│   │   │   ├── Base.pm
│   │   │   ├── Controller
│   │   │   │   └── Root.pm
│   │   │   ├── Dispatcher.pm
│   │   │   ├── Plugin
│   │   │   │   └── Session.pm
│   │   │   ├── Request.pm
│   │   │   ├── Response.pm
│   │   │   ├── Util.pm
│   │   │   ├── View.pm
│   │   │   └── ViewFunctions.pm
│   │   └── Web.pm
│   └── MyApp.pm
├── script
│   ├── app.psgi
│   ├── setup.sh
│   └── teng-schema-dumper.pl
├── static
│   ├── 404.html
│   ├── 500.html
│   ├── 502.html
│   ├── 503.html
│   ├── 504.html
│   ├── css
│   │   └── main.css
│   ├── js
│   │   ├── main.js
│   │   └── xsrf-token.js
│   └── robots.txt
├── t
│   ├── Controller
│   │   └── Root.t
│   ├── Using.t
│   ├── Util.pm
│   └── lib
│       └── Test
│           └── MyApp
│               ├── Factory.pm
│               └── Mechanize.pm
└── template
    ├── include
    │   └── pager.tx
    ├── index.tx
    ├── user
    │   └── show.tx
    └── wrapper
        └── layout.tx
```

This Flavor under developping.
