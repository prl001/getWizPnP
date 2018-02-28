package Beyonwiz::PPModules;

my $Copyright = 'Copyright 2008-2018 Peter Lamb.
See accompanying LICENSE file for redistribution conditions.';

# Dummy module to force dynamically loaded modules used by
# DateTime and its submodules to be included when compiling using pp.
# Referenced when compiling using pp (in make compile).
# Otherwise not referenced.

use Params::Validate::XS;
use Params::Validate::PP;
use Class::Load::XS;
use Class::Load::PP;
use DateTime::Format::Natural::Calc;
use DateTime::Format::Natural::Compat;
use DateTime::Format::Natural::Utils;
use DateTime::Format::Natural::Wrappers;
use DateTime::Format::Natural::Duration;
use DateTime::Format::Natural::Extract;
use DateTime::Format::Natural::Helpers;
use DateTime::Format::Natural::Rewrite;
use DateTime::Format::Natural::Lang::EN;
use DateTime::Format::Natural::Expand;

use DateTime::TimeZone::Local::Unix;
use DateTime::TimeZone::Local::Win32;

use DateTime::TimeZone::OlsonDB;
use DateTime::TimeZone::OlsonDB::Observance;
use DateTime::TimeZone::OlsonDB::Rule;
use DateTime::TimeZone::OlsonDB::Zone;

use DateTime::TimeZone::Australia::Adelaide;
use DateTime::TimeZone::Australia::Brisbane;
use DateTime::TimeZone::Australia::Broken_Hill;
use DateTime::TimeZone::Australia::Currie;
use DateTime::TimeZone::Australia::Darwin;
use DateTime::TimeZone::Australia::Eucla;
use DateTime::TimeZone::Australia::Hobart;
use DateTime::TimeZone::Australia::Lindeman;
use DateTime::TimeZone::Australia::Lord_Howe;
use DateTime::TimeZone::Australia::Melbourne;
use DateTime::TimeZone::Australia::Perth;
use DateTime::TimeZone::Australia::Sydney;

1;
