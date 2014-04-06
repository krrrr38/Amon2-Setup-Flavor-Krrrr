package Amon2::Setup::Flavor::Krrrr;
use utf8;
use strict;
use warnings FATAL => 'all';
use parent qw(Amon2::Setup::Flavor);
use String::Random;
our $VERSION = '0.01';

# override assets method
sub assets {()}

sub run {
    my $self = shift;

    $self->write_template();

    $self->write_web_pms();

    $self->write_controllers();

    $self->write_plugins();

    $self->write_view();

    $self->write_view_functions();

    $self->write_makefile_pl();

    $self->write_tests();

    $self->write_test_libs();

    $self->write_static_files();

    $self->write_scripts();

    $self->write_dbs();

    $self->write_configs();

    $self->write_sqls();

    $self->write_t_util_pm(); # TODO

    $self->write_package();

    $self->write_bowers();
}

sub write_template {
    my ($self, $base) = @_;
    $base ||= 'template';

    $self->write_file("$base/index.tx", <<'...');
[% WRAPPER 'wrapper/layout.tx' %]

<h1 style="padding: 70px; text-align: center; font-size: 80px; line-height: 1; letter-spacing: -2px;">Hello, Amon2 world!</h1>

<form method="POST" action="/post">
    Username : <input type="text" name="name"/>
    <input type="submit" value="Create"/>
</form>

<ul>
  [% FOR entry IN entries %]
    <li>[% entry.eid %]. [% entry.title %]</li>
  [% END %]
</ul>
[% INCLUDE 'include/pager.tx' WITH pager=pager %]
[% END %]
...

    $self->write_file("$base/user/show.tx", <<'...');
[% WRAPPER 'wrapper/layout.tx' %]

<h1 style="padding: 70px; text-align: center; font-size: 80px; line-height: 1; letter-spacing: -2px;">User Page</h1>
<div>
  [% IF user %]
    <div>
      name : [% user.name %]
      info : [% info %]
    </div>
    <ul>
      [% FOR entry in entries %]
        <li>[% entry.title %] : [% entry.created_at %]</li>
      [% END %]
    </ul>
  [% ELSE %]
    user does not exist
  [% END %]
</div>

[% END %]
...

    $self->write_file("$base/wrapper/layout.tx", <<'...');
<!Doctype HTML>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>[% title || '<%= $dist %>' %]</title>
    <meta http-equiv="Content-Style-Type" content="text/css" />
    <meta http-equiv="Content-Script-Type" content="text/javascript" />
    <meta name="viewport" content="width=device-width, minimum-scale=1.0, maximum-scale=1.0" />
    <meta name="format-detection" content="telephone=no" />
<% $tags -%>
    <link href="[% static_file('/static/css/main.css') %]" rel="stylesheet" type="text/css" media="screen" />
    <script src="[% static_file('/static/js/main.js') %]"></script>
    <script src="[% static_file('/static/js/xsrf-token.js') %]"></script>
    <!--[if lt IE 9]>
        <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
</head>
<body[% IF bodyID %] id="[% bodyID %]"[% END %]>
    <div class="navbar navbar-fixed-top">
    </div><!-- /.navbar -->
    <div class="container">
        <div id="main">
            [% content %]
        </div>
        <footer class="footer">
        </footer>
    </div>
</body>
</html>
...

    $self->write_file("$base/include/pager.tx", <<'...');
[% IF pager %]
    <div class="pagination">
        <ul>
            [% IF pager.previous_page %]
                <li class="prev"><a href="<: uri_with({page => $pager.previous_page}) :>" rel="previous">&larr; Back</a><li>
            [% ELSE %]
                <li class="prev disabled"><a href="#">&larr; Back</a><li>
            [% END %]

            [% IF pager.can('pages_in_navigation') %]
                [% # IF Data::Page::Navigation is loaded  %]
                [% FOR page IN pager.pages_in_navigation(5) -%]
                    <li [% IF pager.current_page == page %]class="active"[% END %]><a href="[% uri_with({page => page}) %]">[% page %]</a></li>
                [% END -%]
            [% ELSE %]
                <li><a href="#">[% pager.current_page %]</a></li>
            [% END %]

            [% IF pager.next_page %]
                <li class="next"><a href="<: uri_with({page => $pager.next_page()}) :>" rel="next">Next &rarr;</a><li>
            [% ELSE %]
                <li class="next disabled"><a href="#">Next &rarr;</a><li>
            [% END %]
        </ul>
    </div>
[% END %]
...
}

sub write_web_pms {
  my ($self) = @_;

  $self->write_file('lib/<<PATH>>/Web.pm', <<'...');
package <% $module %>::Web;
use strict;
use warnings;
use utf8;
use parent qw/<% $module %>::Web::Base/;

use Encode qw/decode_utf8/;

sub user {
    my ($self) = @_;

    $self->{_user} //= do {
        my $token = $self->req->cookies->{'token'} or return '';
        $self->db->single('user' => {
            token => $token,
        });
    };
}

sub string_param {
    my ($self, $key) = @_;

    if (wantarray) {
      map {decode_utf8 $_} $self->_parameters->get_all($key);
    }
    else {
      decode_utf8 $self->_parameters->get($key) // "";
    }
}

sub number_param {
    my ($self, $key) = @_;

    if (wantarray) {
      map {$_+0} $self->_parameters->get_all($key);
    }
    else {
      my $value = $self->_parameters->get($key) // "";
      $value+0;
    }
}

1;
...

  $self->write_file('lib/<<PATH>>/Web/Base.pm', <<'...');
package <% $module %>::Web::Base;
use strict;
use warnings;
use utf8;
use parent qw/<% $module %> Amon2::Web/;
use File::Spec;
use Hash::MultiValue;

use <% $module %>::Web::Request;
use <% $module %>::Web::Response;
sub create_request  { <% $module %>::Web::Request->new($_[1], $_[0]) }
sub create_response { shift; <% $module %>::Web::Response->new(@_) }

# dispatcher
use <% $module %>::Web::Dispatcher;
sub dispatch {
    return (<% $module %>::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::JSON',
    '+<% $module %>::Web::Plugin::Session',
);

# setup view
use <% $module %>::Web::View;
{
    sub create_view {
        my $view = <% $module %>::Web::View->make_instance(__PACKAGE__);
        no warnings 'redefine';
        *<% $module %>::Web::create_view = sub { $view }; # Class cache.
        $view
    }
}

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ( $c ) = @_;
        # ...
        return;
    },
);

sub _parameters {
    my $self = shift;

    $self->{_parameters} //= do {
        my $query = $self->request->query_parameters;
        my $body  = $self->request->body_parameters;
        my $path  = Hash::MultiValue->new(%{$self->{args}});
        Hash::MultiValue->new($query->flatten, $body->flatten, $path->flatten);
    };
}

1;
...

    $self->write_file("lib/<<PATH>>/Web/Request.pm", <<'...');
package <% $module %>::Web::Request;
use strict;
use warnings;
use utf8;
use parent qw/Amon2::Web::Request/;
1;
...

    $self->write_file("lib/<<PATH>>/Web/Response.pm", <<'...');
package <% $module %>::Web::Response;
use strict;
use warnings;
use utf8;
use parent qw/Amon2::Web::Response/;
1;
...

    $self->write_file("lib/<<PATH>>/Web/Dispatcher.pm", <<'...');
package <% $module %>::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Module::Find qw(useall);

# Load all controller classes at loading time.
useall('<% $module %>::Web::Controller');

base '<% $module %>::Web::Controller';

any '/'           => 'Root#index';
any '/user/:name' => 'Root#user';
post '/post'      => 'Root#post';

1;
...

    $self->write_file("lib/<<PATH>>/Web/Util.pm", <<'...');
package <% $module %>::Web::Util;
use strict;
use warnings;
use utf8;

use String::Random;
use DateTime;
use DateTime::Format::MySQL;

our $TIME_ZONE = 'Asia/Tokyo';

sub now {
    DateTime->now(time_zone => $TIME_ZONE);
}

sub date_to_db_now {
    my ($self) = @_;
    $self->date_to_db($self->now);
}

sub date_to_db {
    my ($self, $dt) = @_;
    DateTime::Format::MySQL->format_datetime($dt);
}

sub random_token {
    String::Random->new->randregex('[A-Za-z0-9]{32}');
}

1;
...
}

sub write_controllers {
    my ($self) = @_;

    $self->write_file("lib/<<PATH>>/Web/Controller/Root.pm", <<'...');
package <% $module %>::Web::Controller::Root;
use strict;
use warnings;
use utf8;

use <% $module %>::Web::Util;

sub index {
    my ($self, $c) = @_;

    my $counter = $c->session->get('counter') || 0;
    $c->session->set('counter' => $counter);

    my $page = $c->number_param('page') || 1;
    my ($entries, $pager) = $c->db->search_with_pager('entry', {}, {order_by => 'created_at', page => $page, rows => 20});
    return $c->render('index.tx', {entries => $entries, pager => $pager});
}

sub user {
    my ($self, $c) = @_;

    my $username = $c->string_param('name');
    my $user = $c->db->single('user' => {
        name => $username,
    });

    my @entries = $user->fetch_entries;
    return $c->render('user/show.tx', {
        user    => $user,
        entries => \@entries,
        info    => $user->get_user_info,
    });
}

sub post {
    my ($self, $c) = @_;

    my $username = $c->string_param('name');
    my $user = $c->db->insert('user' => {
        name       => $username,
        token      => <% $module %>::Web::Util->random_token,
        created_at => <% $module %>::Web::Util->now,
    });

    if ($user) {
        return $c->redirect('/user/' . $user->name);
    }
    else {
        return $c->redirect('/');
    }
}

1;
...
}

sub write_plugins {
    my ($self) = @_;

    my $rand_str = String::Random->new->randregex('[A-Za-z0-9]{32}');
    $self->write_file("lib/<<PATH>>/Web/Plugin/Session.pm", <<'...', {secret => $rand_str});
package <% $module %>::Web::Plugin::Session;
use strict;
use warnings;
use utf8;

use Amon2::Util;
use HTTP::Session2::ClientStore;

sub init {
    my ($class, $c) = @_;

    # Validate XSRF Token.
    $c->add_trigger(
        BEFORE_DISPATCH => sub {
            my ( $c ) = @_;
            if ($c->req->method ne 'GET' && $c->req->method ne 'HEAD') {
                my $token = $c->req->header('X-XSRF-TOKEN') || $c->req->param('XSRF-TOKEN');
                unless ($c->session->validate_xsrf_token($token)) {
                    return $c->create_simple_status_page(
                        403, 'XSRF detected.'
                    );
                }
            }
            return;
        },
    );

    Amon2::Util::add_method($c, 'session', \&_session);

    # Inject cookie header after dispatching.
    $c->add_trigger(
        AFTER_DISPATCH => sub {
            my ( $c, $res ) = @_;
            if ($c->{session} && $res->can('cookies')) {
                $c->{session}->finalize_plack_response($res);
            }
            return;
        },
    );
}

# $c->session() accessor.
sub _session {
    my $self = shift;

    if (!exists $self->{session}) {
        $self->{session} = HTTP::Session2::ClientStore->new(
            env => $self->req->env,
            secret => '<% $secret %>',
        );
    }
    return $self->{session};
}

1;
__END__

=head1 DESCRIPTION

This module manages session for <% $module %>.
...
}


sub write_view {
    my ($self, %args) = @_;

    my $path = $args{path} || 'lib/<<PATH>>/Web/View.pm';
    $args{package} ||= "$self->{module}::Web::View";
    $args{view_functions_package} ||= "$self->{module}::Web::ViewFunctions";
    $self->write_file($path, <<'...', \%args);
package <% $package %>;
use strict;
use warnings;
use utf8;
use Carp ();
use File::Spec ();

use Text::Xslate 1.6001;
use <% $view_functions_package %>;

# setup view class
sub make_instance {
    my ($class, $context) = @_;
    Carp::croak("Usage: <% $module %>::View->make_instance(\$context_class)") if @_!=2;

    my $view_conf = $context->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        my $tmpl_path = File::Spec->catdir($context->base_dir(), 'template');
        if ( -d $tmpl_path ) {
            # tmpl
            $view_conf->{path} = [ $tmpl_path ];
        } else {
            my $share_tmpl_path = eval { File::Spec->catdir(File::ShareDir::dist_dir('<% $module %>'), 'template') };
            if ($share_tmpl_path) {
                # This application was installed to system.
                $view_conf->{path} = [ $share_tmpl_path ];
            } else {
                Carp::croak("Can't find template directory. tmpl Is not available.");
            }
        }
    }
    my $view = Text::Xslate->new(+{
        'syntax'   => 'TTerse',
        'module'   => [
            'Text::Xslate::Bridge::Star',
            '<% $view_functions_package %>',
        ],
        'function' => {
        },
        ($context->debug_mode ? ( warn_handler => sub {
            Text::Xslate->print( # print method escape html automatically
                '[[', @_, ']]',
            );
        } ) : () ),
        %$view_conf
    });
    return $view;
}

1;
...
}

sub write_view_functions {
    my ($self, %args) = @_;

    my $path = $args{path} || 'lib/<<PATH>>/Web/ViewFunctions.pm';
    $args{package} ||= "$self->{module}::Web::ViewFunctions";
    $self->write_file($path, <<'...', \%args);
package <% $package %>;
use strict;
use warnings;
use utf8;
use parent qw(Exporter);
use Module::Functions;
use File::Spec;

our @EXPORT = get_public_functions();

sub commify {
    local $_  = shift;
    1 while s/((?:\A|[^.0-9])[-+]?\d+)(\d{3})/$1,$2/s;
    return $_;
}

sub c { Amon2->context() }
sub uri_with { Amon2->context()->req->uri_with(@_) }
sub uri_for { Amon2->context()->uri_for(@_) }

{
    my %static_file_cache;
    sub static_file {
        my $fname = shift;
        my $c = <% $module %>->context;
        if (not exists $static_file_cache{$fname}) {
            my $fullpath = File::Spec->catfile($c->base_dir(), $fname);
            $static_file_cache{$fname} = (stat $fullpath)[9];
        }
        return $c->uri_for(
            $fname, {
                't' => $static_file_cache{$fname} || 0
            }
        );
    }
}

1;
...
}

sub write_makefile_pl {
    my ($self, $deps) = @_;
    $deps->{'Module::Functions'} ||= 2;

    $self->write_file('Build.PL', <<'...', {deps => $deps});
use strict;
use warnings;
use Module::Build;
use Module::CPANfile;

my $file = Module::CPANfile->load("cpanfile");
my $prereq = $file->prereq_specs;

my $build = Module::Build->subclass(
    code => q{
        sub ACTION_install {
            die "Do not install web application.\n";
        }

        # do not make blib.
        sub ACTION_code {
            my $self = shift;
            $self->depends_on('config_data');
        }

        # run prove
        sub ACTION_test {
            my $self = shift;
            my $tests = $self->find_test_files;

            require App::Prove;
            my $prove = App::Prove->new();
            $prove->process_args('-l', @$tests);
            $prove->run();
        }
    }
)->new(
    license              => 'unknown',
    dynamic_config       => 0,

    build_requires       => {
        $prereq->{build} ? %{$prereq->{build}->{requires}} : (),
        $prereq->{test} ? %{$prereq->{test}->{requires}} : (),
    },
    configure_requires   => {
        %{$prereq->{configure}->{requires}},
    },
    requires             => {
        %{$prereq->{runtime}->{requires}},
    },

    no_index    => { 'directory' => [ 'inc' ] },
    name        => '<% $module %>',
    module_name => '<% $module %>',
    author        => 'Ken Kaizu <k.kaizu38@gmail.com>',
    dist_abstract => 'A web site based on Amon2',

    test_files => 't/',
    recursive_test_files => 1,

    create_readme  => 0,
    create_license => 0,
);
$build->create_build_script();
...

    $self->write_file('cpanfile', <<'...', {deps => $deps});
requires 'perl', '5.14.2';
requires 'Amon2', '6.00';
requires 'DateTime';
requires 'DateTime::Format::MySQL', '0.04';
requires 'DBI';
requires 'HTML::FillInForm::Lite', '1.11';
requires 'HTTP::Session2', '0.04';
requires 'JSON', '2.50';
requires 'JSON::XS', '3.01';
requires 'JSON::Types', '0.05';
requires 'Module::Functions', '2';
requires 'Module::Find', '0.11';
requires 'Plack';
requires 'Plack::Middleware::ReverseProxy', '0.09';
requires 'Params::Util';
requires 'Router::Boom', '0.06';
requires 'Starlet', '0.20';
requires 'String::Random';
requires 'Sub::Identify';
requires 'Teng', '0.18';
requires 'Text::Xslate', '2.0009';
requires 'Time::Piece', '1.20';

on 'configure' => sub {
   requires 'Module::Build', '0.38';
   requires 'Module::CPANfile', '0.9010';
};

on 'test' => sub {
   requires 'Test::More', '0.98';
   requires 'Test::Fatal', '0.013';
   requires 'Test::Class', '0.39';
   requires 'Test::WWW::Mechanize::PSGI';
};
...
}

sub write_tests {
    my ($self, $more) = @_;

    $self->write_file("t/Using.t", <<'...');
package t::Using;

use t::Util;
use parent qw(Test::Class);

sub _use_ok : Tests {
    use_ok $_ for qw(
        <% $module %>
        <% $module %>::Web
        <% $module %>::Web::Base
        <% $module %>::Web::ViewFunctions
        <% $module %>::Web::Dispatcher
    );
}
...

    $self->write_file('t/Controller/Root.t', <<'...');
package t::Controller::Root;

use t::Util;
use lib 't/lib';
use parent qw(Test::Class);

use Test::<% $module %>::Mechanize;
use Test::<% $module %>::Factory;

sub _index : Tests {
    subtest 'normal access' => sub {
        my $mech = create_mech;
        $mech->get('/');
        is $mech->res->code, 200, 'status return 200';
    };
}

sub _db_example : Tests {
    my $user = create_user(name => "yunotti");
    ok $user;
    is $user->name, "yunotti";
}
...
}


sub write_test_libs {
    my ($self) = @_;

    $self->write_file('t/lib/Test/<<PATH>>/Mechanize.pm', <<'...');
package Test::<% $module %>::Mechanize;

use strict;
use warnings;
use utf8;

use parent qw(Test::WWW::Mechanize::PSGI);

use Exporter::Lite;
our @EXPORT = qw(create_mech);

use Plack::Util;

my $app = Plack::Util::load_psgi 'script/app.psgi';

sub create_mech (;%) {
    return __PACKAGE__->new(@_);
}

sub new {
    my ($class, %opts) = @_;

    $class->SUPER::new(
        app => $app,
        %opts,
    );
}

1;
...

    $self->write_file('t/lib/Test/<<PATH>>/Factory.pm', <<'...');
package Test::<% $module %>::Factory;

use strict;
use warnings;
use utf8;

use Exporter::Lite;
our @EXPORT = qw(
    create_dbh
    create_user
);

use String::Random qw(random_regex);

use <% $module %>;
use <% $module %>::Web::Util;

my $dbh;
sub create_dbh {
    $dbh //= do {
        my $db_config = <% $module %>->config->{DBI} || die "Missing configuration for DBI";

        <% $module %>::DB->new(
            schema => <% $module %>::DB::Schema->instance,
            connect_info => [@$db_config],
            on_connect_do => [
                'SET SESSION sql_mode=STRICT_TRANS_TABLES;',
            ],
        ) or die "connect test db failed";
    };
}

sub create_user {
    my %args = @_;

    my $name       = $args{name} // random_regex('test_user_\w{15}');
    my $token      = $args{token} // <% $module %>::Web::Util->random_token;
    my $created_at = $args{created_at} // <% $module %>::Web::Util->now;
    my $updated_at = $args{updated_at} // <% $module %>::Web::Util->now;

    create_dbh->insert('user' => {
        name       => $name,
        token      => $token,
        created_at => $created_at,
        updated_at => $updated_at,
    });
}

my $first_flag = 0;
do {
    if (!$first_flag) {
        my $dbh = create_dbh;
        my $tables = $dbh->{dbh}->table_info('', '', '%', 'TABLE')->fetchall_arrayref({});
        $dbh->do("TRUNCATE `$_`") for map { $_->{TABLE_NAME} } @$tables;
        $first_flag = 1;
    }
};

1;
...
}

sub write_static_files {
    my ($self, $base) = @_;
    $base ||= 'static';

    # for my $asset (@ASSETS) {
    #     $self->write_asset($asset, $base);
    # }

    for my $status (qw/404 500 502 503 504/) {
        $self->write_status_file("static/$status.html", $status);
    }

    $self->write_file("$base/robots.txt", '');

    $self->write_file("$base/js/main.js", <<'...');
if (typeof(window.console) == "undefined") { console = {}; console.log = console.warn = console.error = function(a) {}; }
...

    $self->write_file("$base/css/main.css", <<'...');
body {
    margin-top: 50px;
}

footer {
    text-align: right;
    padding-right: 10px;
    padding-top: 2px; }
    footer a {
        text-decoration: none;
        color: black;
        font-weight: bold;
    }

/* smart phones */
@media screen and (max-device-width: 480px) {
}
...

    $self->write_file("$base/js/xsrf-token.js", <<'...');
var <% $module %> = <% $module %> || {};
<% $module %>.getXSRFToken = function() {
    var token;

    return function() {
        if(token === undefined) {
            var cookies = document.cookie.split(/\s*;\s*/);
            for (var i=0,l=cookies.length; i<l; i++) {
                var matched = cookies[i].match(/^XSRF-TOKEN=(.*)$/);
                if (matched) {
                    token = matched[1];
                    break;
                }
            }
        }
        return token;
    };
}();

window.onload = function() {
    var xsrf_token = <% $module %>.getXSRFToken();
    var forms = document.getElementsByTagName('form');
    for(var i = 0; i < forms.length; ++i) {
        var method = forms[i].getAttribute('form');
        if (method === 'get' || method === 'GET') {
            return;
        }

        var input = document.createElement('input');
        input.setAttribute('type', 'hidden');
        input.setAttribute('name',  'XSRF-TOKEN');
        input.setAttribute('value',  xsrf_token);

        forms[i].appendChild(input);
    };

};
...
}

sub write_scripts {
    my ($self) = @_;

    $self->write_file('script/teng-schema-dumper.pl', <<'...', {lcmodule => lc($self->{dist})});
#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use Teng::Schema::Dumper;

my $dbh = DBI->connect("dbi:mysql:dbname=<% $lcmodule %>_development", "nobody", "nobody") or die;
# my $dbh = DBI->connect('dbi:SQLite:dbname=db/<% $lcmodule %>_development.db') or die;
print Teng::Schema::Dumper->dump(
    dbh       => $dbh,
    namespace => 'My::DB',
);
...

    $self->write_file('script/setup.sh', <<'...', {lcmodule => lc($self->{dist})});
#!/bin/sh

echo "Installing dependencies with carton"
carton install

mysqladmin -uroot drop <% $lcmodule %>_development -f > /dev/null 2>&1
mysqladmin -uroot create <% $lcmodule %>_development
echo "Database \"<% $lcmodule %>_development\" created"
echo "Initializing \"<% $lcmodule %>_development\""
mysql -uroot <% $lcmodule %>_development < db/schema.sql

mysqladmin -uroot drop <% $lcmodule %>_test -f > /dev/null 2>&1
mysqladmin -uroot create <% $lcmodule %>_test
echo "Database \"<% $lcmodule %>_test\" created"
echo "Initializing \"<% $lcmodule %>_test\""
mysql -uroot <% $lcmodule %>_test < db/schema.sql

if [ $PRODUCTION ]; then
    mysqladmin -uroot create <% $lcmodule %>_test
    echo "Database \"<% $lcmodule %>_production\" created"
    echo "Initializing \"<% $lcmodule %>_test\""
    mysql -uroot <% $lcmodule %>_production < db/schema.sql
fi

echo "Done."
...

    $self->write_file('script/app.psgi', <<'...');
#!perl
use strict;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../lib');
use Plack::Builder;

use <% $module %>::Web;
use <% $module %>;
use URI::Escape;
use File::Path ();

my $app = builder {
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/static/)},
        root => File::Spec->catdir(dirname(__FILE__), '..');
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/robots\.txt|/favicon\.ico)$},
        root => File::Spec->catdir(dirname(__FILE__), '..', 'static');
    enable 'Plack::Middleware::ReverseProxy';

    <% $module %>::Web->to_app();
};
unless (caller) {
    my $port        = 5000;
    my $host        = '127.0.0.1';
    my $max_workers = 4;

    require Getopt::Long;
    require Plack::Loader;
    my $p = Getopt::Long::Parser->new(
        config => [qw(posix_default no_ignore_case auto_help)]
    );
    $p->getoptions(
        'p|port=i'      => \$port,
        'host=s'      => \$host,
        'max-workers' => \$max_workers,
        'version!'    => \my $version,
        'c|config=s'  => \my $config_file,
    );
    if ($version) {
        print "<% $module %>: $<% $module %>::VERSION\n";
        exit 0;
    }
    if ($config_file) {
        my $config = do $config_file;
        Carp::croak("$config_file: $@") if $@;
        Carp::croak("$config_file: $!") unless defined $config;
        unless ( ref($config) eq 'HASH' ) {
            Carp::croak("$config_file does not return HashRef.");
        }
        no warnings 'redefine';
        *<% $module %>::load_config = sub { $config }
    }

    print "<% $module %>: http://${host}:${port}/\n";

    my $loader = Plack::Loader->load('Starlet',
        port        => $port,
        host        => $host,
        max_workers => $max_workers,
    );
    return $loader->run($app);
}
return $app;
...

    $self->write_file('.gitignore', <<'...');
Makefile
/inc/
MANIFEST
*.bak
*.old
nytprof.out
nytprof/
*.db
/blib/
pm_to_blib
META.json
META.yml
MYMETA.json
MYMETA.yml
/Build
/_build/
/local/
/.carton/
tmp
*~
static/js/lib
...
}

sub write_dbs {
  my ($self) = @_;

  $self->write_file('lib/<<PATH>>/DB.pm', <<'...');
package <% $module %>::DB;
use strict;
use warnings;
use utf8;
use parent qw(Teng);

__PACKAGE__->load_plugin('Count');
__PACKAGE__->load_plugin('Replace');
__PACKAGE__->load_plugin('Pager');

1;
...

  $self->write_file('lib/<<PATH>>/DB/Schema.pm', <<'...');
package <% $module %>::DB::Schema;
use strict;
use warnings;
use utf8;

use DateTime::Format::MySQL;
use Teng::Schema::Declare;

base_row_class '<% $module %>::DB::Row';

table {
    name 'entry';
    pk 'eid';
    columns (
        {name => 'eid', type => 4},
        {name => 'uid', type => 4},
        {name => 'title', type => 12},
        {name => 'updated_at', type => 11},
        {name => 'created_at', type => 11},
    );

    inflate qr/_at$/ => sub {
        DateTime::Format::MySQL->parse_datetime(shift);
    };

    deflate qr/_at$/ => sub {
        DateTime::Format::MySQL->format_datetime(shift);
    };
};

table {
    name 'user';
    pk 'uid';
    columns (
        {name => 'uid', type => 4},
        {name => 'name', type => 12},
        {name => 'token', type => 1},
        {name => 'updated_at', type => 11},
        {name => 'created_at', type => 11},
    );

    inflate qr/_at$/ => sub {
        DateTime::Format::MySQL->parse_datetime(shift);
    };

    deflate qr/_at$/ => sub {
        DateTime::Format::MySQL->format_datetime(shift);
    };
};

1;
...

  $self->write_file('lib/<<PATH>>/DB/Row.pm', <<'...');
package <% $module %>::DB::Row;
use strict;
use warnings;
use utf8;
use parent qw(Teng::Row);

1;
...

    $self->write_file('lib/<<PATH>>/DB/Row/User.pm', <<'...');
package <% $module %>::DB::Row::User;
use strict;
use warnings;
use utf8;
use parent qw/<% $module %>::DB::Row/;

sub get_user_info {
    my $self = shift;
    join(' ', ($self->uid, $self->name, $self->created_at));
}

sub fetch_entries {
    my ($self, $where, @args) = @_;
    $where->{uid} = $self->uid;
    $self->handle->search(entry => $where, @args);
}

1;
...

  $self->write_file('lib/<<PATH>>/DB/Row/Entry.pm', <<'...');
package <% $module %>::DB::Row::Entry;
use strict;
use warnings;
use utf8;
use parent qw/<% $module %>::DB::Row/;

sub fetch_user {
    my ($self, $where, @args) = @_;
    $where->{uid} = $self->uid;
    $self->handle->single(user => $where, @args);
}

1;
...
}

sub write_configs {
  my ($self) = @_;

  for my $env (qw(development production test)) {
    $self->write_file("config/${env}.pl", <<'...', {env => $env, lcmodule => lc($self->{dist})});
my $db_name = '<% $lcmodule %>_<% $env %>';
+{
    'DBI' => [
        "dbi:mysql:dbname=$db_name", 'nobody', 'nobody',
        +{
            mysql_enable_utf8 => 1,
            PrintError        => 0,
            RaiseError        => 1,
        }
    ],
};
...
  }
}

sub write_sqls {
  my ($self) = @_;

  $self->write_file("db/schema.sql", <<'...');
CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS user (
    `uid` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(32) NOT NULL,
    `token` CHAR(32) NOT NULL,

    `updated_at` TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP NOT NULL,

    PRIMARY KEY (uid),
    UNIQUE KEY (name),
    KEY (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS entry (
    `eid` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uid` INT UNSIGNED NOT NULL,
    `title` VARCHAR(32) NOT NULL,

    `updated_at` TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP NOT NULL,

    PRIMARY KEY (eid),
    key (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
...
}


sub write_status_file {
    my ($self, $fname, $status) = @_;

    my $message = {
        '503' => 'Service Unavailable',
        '502' => 'Bad Gateway',
        '500' => 'Internal Server Error',
        '504' => 'Gateway Timeout',
        '404' => 'Not Found'
    }->{$status};
    $self->write_file($fname, <<'...', status => $status, status_message => $message);
<!doctype html>
<html>
    <head>
        <meta charset=utf-8 />
        <style type="text/css">
            body {
                text-align: center;
                font-family: 'Menlo', 'Monaco', Courier, monospace;
                background-color: whitesmoke;
                padding-top: 10%;
            }
            .number {
                font-size: 800%;
                font-weight: bold;
                margin-bottom: 40px;
            }
            .message {
                font-size: 400%;
            }
        </style>
    </head>
    <body>
        <div class="number"><%= $status %></div>
        <div class="message"><%= $status_message %></div>
    </body>
</html>
...
}

sub write_t_util_pm {
    my ($self, $exports, $more) = @_;
    $exports ||= [];
    $more ||= '';

    $self->write_file('t/Util.pm', <<'...' . $more . "\n1;\n", {exports => $exports});
package t::Util;
BEGIN {
    unless ($ENV{PLACK_ENV}) {
        $ENV{PLACK_ENV} = 'test';
    }
    if ($ENV{PLACK_ENV} eq 'deployment') {
        die "Do not run a test script on deployment environment";
    }
}
use File::Spec;
use File::Basename;
use lib File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..', 'extlib', 'lib', 'perl5'));
use lib File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..', 'lib'));
use parent qw/Exporter/;
use Test::More;
use utf8;

our @EXPORT = qw(slurp);

{
    # utf8 hack.
    binmode Test::More->builder->$_, ":utf8" for qw/output failure_output todo_output/;
    no warnings 'redefine';
    my $code = \&Test::Builder::child;
    *Test::Builder::child = sub {
        my $builder = $code->(@_);
        binmode $builder->output,         ":utf8";
        binmode $builder->failure_output, ":utf8";
        binmode $builder->todo_output,    ":utf8";
        return $builder;
    };
}

sub slurp {
    my $fname = shift;
    open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
    do { local $/; <$fh> };
}

sub import {
    my $class = shift;

    strict->import;
    warnings->import;
    utf8->import;
    my ($package, $file) = caller;

    my @options = (
        -common => qq[
            use Test::More;
            use Test::Fatal;
            binmode Test::More->builder->output, ":utf8";
            binmode Test::More->builder->failure_output, ":utf8";
            binmode Test::More->builder->todo_output, ":utf8";

            use parent 'Test::Class';
            END {
                $package->runtests if \$0 eq "\Q$file\E";
            }
        ],
    );
    my %specified = map { $_ => 1 } -common, @_;

    my $code = '';
    while (my ($option, $fragment) = splice @options, 0, 2) {
        $code .= $fragment if delete $specified{$option};
    }
    die 'Invalid options: ' . join ', ', keys %specified if %specified;

    eval "package $package; $code";
    die $@ if $@;
}
...

    $self->write_file('lib/<<PATH>>/UserAgent.pm', <<'...');
package <% $module %>::UserAgent;

use strict;
use warnings;
use parent qw/LWP::UserAgent/;

use <% $module %>;

sub new {
    my $class = shift;
    my %args  = @_;
    my $self  = $class->SUPER::new(%args);
    my $service = $args{service};
    my $agent   = $args{agent} ||
        ($service ? sprintf('<% $module %>::UserAgent(%s)/%s', $service, $<% $module %>::VERSION) :
                   sprintf('<% $module %>::UserAgent/%s', $<% $module %>::VERSION));
    $self->agent($agent);
    $self->timeout($args{timeout} || 10);
    $self;
}

1;
...
}

sub write_package {
    my ($self) = @_;

    $self->write_file('lib/<<PATH>>.pm', <<'...');
package <% $module %>;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
use <% $module %>::DB::Schema;
use <% $module %>::DB;

our $VERSION='0.01';

use parent qw/Amon2/;
# Enable project local mode.
__PACKAGE__->make_local_context();

my $schema = <% $module %>::DB::Schema->instance;

sub db {
    my $c = shift;
    if (!exists $c->{db}) {
        my $conf = $c->config->{DBI}
            or die "Missing configuration about DBI";
        $c->{db} = <% $module %>::DB->new(
            schema       => $schema,
            connect_info => [@$conf],
            # I suggest to enable following lines if you are using mysql.
            # on_connect_do => [
            #     'SET SESSION sql_mode=STRICT_TRANS_TABLES;',
            # ],
        );
    }
    $c->{db};
}

1;
...
}

sub write_bowers {
    my ($self) = @_;

    $self->write_file('.bowerrc', <<'...');
{
  "directory" : "static/js/lib"
}
...
}

# override method
sub show_banner {
    print <<'...';
--------------------------------------------------------------

Setup script was done! You are ready to run the skelton.
You need following command:

    > carton
    > mysql
        if you wanna change schme
        1. edit db/schema.sql
        2. import into database
        3. change DB::Schema.pm with script/teng-schema-dumper.pl
    > bower (optional)
        bower init && bower install angular # into static/js/lib

You need to setup which include installing the dependencies by:

    > sh script/setup.sh

And then, run your application server:

    > carton exec perl script/app.psgi

--------------------------------------------------------------
...
}

1;
