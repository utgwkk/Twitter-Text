package Twitter::Text::Regexp::Emoji;
use strict;
use warnings;
use utf8;

# internal use only, do not use this module directly.

our $valid_emoji = qr/
    (?:\N{U+01f468}\N{U+01f3fb}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f468}[\N{U+01f3fc}-\N{U+01f3ff}]|\N{U+01f468}\N{U+01f3fc}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f468}[\N{U+01f3fb}\N{U+01f3fd}-\N{U+01f3ff}]|\N{U+01f468}\N{U+01f3fd}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f468}[\N{U+01f3fb}\N{U+01f3fc}\N{U+01f3fe}\N{U+01f3ff}]|\N{U+01f468}\N{U+01f3fe}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f468}[\N{U+01f3fb}-\N{U+01f3fd}\N{U+01f3ff}]|\N{U+01f468}\N{U+01f3ff}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f468}[\N{U+01f3fb}-\N{U+01f3fe}]|\N{U+01f469}\N{U+01f3fb}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f468}[\N{U+01f3fc}-\N{U+01f3ff}]|\N{U+01f469}\N{U+01f3fb}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f469}[\N{U+01f3fc}-\N{U+01f3ff}]|\N{U+01f469}\N{U+01f3fc}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f468}[\N{U+01f3fb}\N{U+01f3fd}-\N{U+01f3ff}]|\N{U+01f469}\N{U+01f3fc}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f469}[\N{U+01f3fb}\N{U+01f3fd}-\N{U+01f3ff}]|\N{U+01f469}\N{U+01f3fd}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f468}[\N{U+01f3fb}\N{U+01f3fc}\N{U+01f3fe}\N{U+01f3ff}]|\N{U+01f469}\N{U+01f3fd}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f469}[\N{U+01f3fb}\N{U+01f3fc}\N{U+01f3fe}\N{U+01f3ff}]|\N{U+01f469}\N{U+01f3fe}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f468}[\N{U+01f3fb}-\N{U+01f3fd}\N{U+01f3ff}]|\N{U+01f469}\N{U+01f3fe}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f469}[\N{U+01f3fb}-\N{U+01f3fd}\N{U+01f3ff}]|\N{U+01f469}\N{U+01f3ff}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f468}[\N{U+01f3fb}-\N{U+01f3fe}]|\N{U+01f469}\N{U+01f3ff}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f469}[\N{U+01f3fb}-\N{U+01f3fe}]|\N{U+01f9d1}\N{U+01f3fb}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f9d1}[\N{U+01f3fb}-\N{U+01f3ff}]|\N{U+01f9d1}\N{U+01f3fc}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f9d1}[\N{U+01f3fb}-\N{U+01f3ff}]|\N{U+01f9d1}\N{U+01f3fd}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f9d1}[\N{U+01f3fb}-\N{U+01f3ff}]|\N{U+01f9d1}\N{U+01f3fe}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f9d1}[\N{U+01f3fb}-\N{U+01f3ff}]|\N{U+01f9d1}\N{U+01f3ff}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f9d1}[\N{U+01f3fb}-\N{U+01f3ff}]|\N{U+01f9d1}\N{U+200d}\N{U+01f91d}\N{U+200d}\N{U+01f9d1}|\N{U+01f46b}[\N{U+01f3fb}-\N{U+01f3ff}]|\N{U+01f46c}[\N{U+01f3fb}-\N{U+01f3ff}]|\N{U+01f46d}[\N{U+01f3fb}-\N{U+01f3ff}]|[\N{U+01f46b}-\N{U+01f46d}])|[\N{U+01f468}\N{U+01f469}\N{U+01f9d1}][\N{U+01f3fb}-\N{U+01f3ff}]?\N{U+200d}(?:\N{U+2695}\N{U+fe0f}|\N{U+2696}\N{U+fe0f}|\N{U+2708}\N{U+fe0f}|[\N{U+01f33e}\N{U+01f373}\N{U+01f393}\N{U+01f3a4}\N{U+01f3a8}\N{U+01f3eb}\N{U+01f3ed}\N{U+01f4bb}\N{U+01f4bc}\N{U+01f527}\N{U+01f52c}\N{U+01f680}\N{U+01f692}\N{U+01f9af}-\N{U+01f9b3}\N{U+01f9bc}\N{U+01f9bd}])|[\N{U+26f9}\N{U+01f3cb}\N{U+01f3cc}\N{U+01f574}\N{U+01f575}](?:[\N{U+fe0f}\N{U+01f3fb}-\N{U+01f3ff}]\N{U+200d}[\N{U+2640}\N{U+2642}]\N{U+fe0f})|[\N{U+01f3c3}\N{U+01f3c4}\N{U+01f3ca}\N{U+01f46e}\N{U+01f471}\N{U+01f473}\N{U+01f477}\N{U+01f481}\N{U+01f482}\N{U+01f486}\N{U+01f487}\N{U+01f645}-\N{U+01f647}\N{U+01f64b}\N{U+01f64d}\N{U+01f64e}\N{U+01f6a3}\N{U+01f6b4}-\N{U+01f6b6}\N{U+01f926}\N{U+01f935}\N{U+01f937}-\N{U+01f939}\N{U+01f93d}\N{U+01f93e}\N{U+01f9b8}\N{U+01f9b9}\N{U+01f9cd}-\N{U+01f9cf}\N{U+01f9d6}-\N{U+01f9dd}][\N{U+01f3fb}-\N{U+01f3ff}]?\N{U+200d}[\N{U+2640}\N{U+2642}]\N{U+fe0f}|(?:\N{U+01f468}\N{U+200d}\N{U+2764}\N{U+fe0f}\N{U+200d}\N{U+01f48b}\N{U+200d}\N{U+01f468}|\N{U+01f469}\N{U+200d}\N{U+2764}\N{U+fe0f}\N{U+200d}\N{U+01f48b}\N{U+200d}[\N{U+01f468}\N{U+01f469}]|\N{U+01f468}\N{U+200d}\N{U+01f468}\N{U+200d}\N{U+01f466}\N{U+200d}\N{U+01f466}|\N{U+01f468}\N{U+200d}\N{U+01f468}\N{U+200d}\N{U+01f467}\N{U+200d}[\N{U+01f466}\N{U+01f467}]|\N{U+01f468}\N{U+200d}\N{U+01f469}\N{U+200d}\N{U+01f466}\N{U+200d}\N{U+01f466}|\N{U+01f468}\N{U+200d}\N{U+01f469}\N{U+200d}\N{U+01f467}\N{U+200d}[\N{U+01f466}\N{U+01f467}]|\N{U+01f469}\N{U+200d}\N{U+01f469}\N{U+200d}\N{U+01f466}\N{U+200d}\N{U+01f466}|\N{U+01f469}\N{U+200d}\N{U+01f469}\N{U+200d}\N{U+01f467}\N{U+200d}[\N{U+01f466}\N{U+01f467}]|\N{U+01f468}\N{U+200d}\N{U+2764}\N{U+fe0f}\N{U+200d}\N{U+01f468}|\N{U+01f469}\N{U+200d}\N{U+2764}\N{U+fe0f}\N{U+200d}[\N{U+01f468}\N{U+01f469}]|\N{U+01f3f3}\N{U+fe0f}\N{U+200d}\N{U+26a7}\N{U+fe0f}|\N{U+01f468}\N{U+200d}\N{U+01f466}\N{U+200d}\N{U+01f466}|\N{U+01f468}\N{U+200d}\N{U+01f467}\N{U+200d}[\N{U+01f466}\N{U+01f467}]|\N{U+01f468}\N{U+200d}\N{U+01f468}\N{U+200d}[\N{U+01f466}\N{U+01f467}]|\N{U+01f468}\N{U+200d}\N{U+01f469}\N{U+200d}[\N{U+01f466}\N{U+01f467}]|\N{U+01f469}\N{U+200d}\N{U+01f466}\N{U+200d}\N{U+01f466}|\N{U+01f469}\N{U+200d}\N{U+01f467}\N{U+200d}[\N{U+01f466}\N{U+01f467}]|\N{U+01f469}\N{U+200d}\N{U+01f469}\N{U+200d}[\N{U+01f466}\N{U+01f467}]|\N{U+01f3f3}\N{U+fe0f}\N{U+200d}\N{U+01f308}|\N{U+01f3f4}\N{U+200d}\N{U+2620}\N{U+fe0f}|\N{U+01f46f}\N{U+200d}\N{U+2640}\N{U+fe0f}|\N{U+01f46f}\N{U+200d}\N{U+2642}\N{U+fe0f}|\N{U+01f93c}\N{U+200d}\N{U+2640}\N{U+fe0f}|\N{U+01f93c}\N{U+200d}\N{U+2642}\N{U+fe0f}|\N{U+01f9de}\N{U+200d}\N{U+2640}\N{U+fe0f}|\N{U+01f9de}\N{U+200d}\N{U+2642}\N{U+fe0f}|\N{U+01f9df}\N{U+200d}\N{U+2640}\N{U+fe0f}|\N{U+01f9df}\N{U+200d}\N{U+2642}\N{U+fe0f}|\N{U+01f415}\N{U+200d}\N{U+01f9ba}|\N{U+01f441}\N{U+200d}\N{U+01f5e8}|\N{U+01f468}\N{U+200d}[\N{U+01f466}\N{U+01f467}]|\N{U+01f469}\N{U+200d}[\N{U+01f466}\N{U+01f467}])|[#*0-9]\N{U+fe0f}?\N{U+20e3}|(?:[©®\N{U+2122}\N{U+265f}]\N{U+fe0f})|[\N{U+203c}\N{U+2049}\N{U+2139}\N{U+2194}-\N{U+2199}\N{U+21a9}\N{U+21aa}\N{U+231a}\N{U+231b}\N{U+2328}\N{U+23cf}\N{U+23ed}-\N{U+23ef}\N{U+23f1}\N{U+23f2}\N{U+23f8}-\N{U+23fa}\N{U+24c2}\N{U+25aa}\N{U+25ab}\N{U+25b6}\N{U+25c0}\N{U+25fb}-\N{U+25fe}\N{U+2600}-\N{U+2604}\N{U+260e}\N{U+2611}\N{U+2614}\N{U+2615}\N{U+2618}\N{U+2620}\N{U+2622}\N{U+2623}\N{U+2626}\N{U+262a}\N{U+262e}\N{U+262f}\N{U+2638}-\N{U+263a}\N{U+2640}\N{U+2642}\N{U+2648}-\N{U+2653}\N{U+2660}\N{U+2663}\N{U+2665}\N{U+2666}\N{U+2668}\N{U+267b}\N{U+267f}\N{U+2692}-\N{U+2697}\N{U+2699}\N{U+269b}\N{U+269c}\N{U+26a0}\N{U+26a1}\N{U+26a7}\N{U+26aa}\N{U+26ab}\N{U+26b0}\N{U+26b1}\N{U+26bd}\N{U+26be}\N{U+26c4}\N{U+26c5}\N{U+26c8}\N{U+26cf}\N{U+26d1}\N{U+26d3}\N{U+26d4}\N{U+26e9}\N{U+26ea}\N{U+26f0}-\N{U+26f5}\N{U+26f8}\N{U+26fa}\N{U+26fd}\N{U+2702}\N{U+2708}\N{U+2709}\N{U+270f}\N{U+2712}\N{U+2714}\N{U+2716}\N{U+271d}\N{U+2721}\N{U+2733}\N{U+2734}\N{U+2744}\N{U+2747}\N{U+2757}\N{U+2763}\N{U+2764}\N{U+27a1}\N{U+2934}\N{U+2935}\N{U+2b05}-\N{U+2b07}\N{U+2b1b}\N{U+2b1c}\N{U+2b50}\N{U+2b55}\N{U+3030}\N{U+303d}\N{U+3297}\N{U+3299}\N{U+01f004}\N{U+01f170}\N{U+01f171}\N{U+01f17e}\N{U+01f17f}\N{U+01f202}\N{U+01f21a}\N{U+01f22f}\N{U+01f237}\N{U+01f321}\N{U+01f324}-\N{U+01f32c}\N{U+01f336}\N{U+01f37d}\N{U+01f396}\N{U+01f397}\N{U+01f399}-\N{U+01f39b}\N{U+01f39e}\N{U+01f39f}\N{U+01f3cd}\N{U+01f3ce}\N{U+01f3d4}-\N{U+01f3df}\N{U+01f3f3}\N{U+01f3f5}\N{U+01f3f7}\N{U+01f43f}\N{U+01f441}\N{U+01f4fd}\N{U+01f549}\N{U+01f54a}\N{U+01f56f}\N{U+01f570}\N{U+01f573}\N{U+01f576}-\N{U+01f579}\N{U+01f587}\N{U+01f58a}-\N{U+01f58d}\N{U+01f5a5}\N{U+01f5a8}\N{U+01f5b1}\N{U+01f5b2}\N{U+01f5bc}\N{U+01f5c2}-\N{U+01f5c4}\N{U+01f5d1}-\N{U+01f5d3}\N{U+01f5dc}-\N{U+01f5de}\N{U+01f5e1}\N{U+01f5e3}\N{U+01f5e8}\N{U+01f5ef}\N{U+01f5f3}\N{U+01f5fa}\N{U+01f6cb}\N{U+01f6cd}-\N{U+01f6cf}\N{U+01f6e0}-\N{U+01f6e5}\N{U+01f6e9}\N{U+01f6f0}\N{U+01f6f3}](?:\N{U+fe0f}|(?!\N{U+fe0e}))|(?:[\N{U+261d}\N{U+26f7}\N{U+26f9}\N{U+270c}\N{U+270d}\N{U+01f3cb}\N{U+01f3cc}\N{U+01f574}\N{U+01f575}\N{U+01f590}](?:\N{U+fe0f}|(?!\N{U+fe0e}))|[\N{U+270a}\N{U+270b}\N{U+01f385}\N{U+01f3c2}-\N{U+01f3c4}\N{U+01f3c7}\N{U+01f3ca}\N{U+01f442}\N{U+01f443}\N{U+01f446}-\N{U+01f450}\N{U+01f466}-\N{U+01f469}\N{U+01f46e}\N{U+01f470}-\N{U+01f478}\N{U+01f47c}\N{U+01f481}-\N{U+01f483}\N{U+01f485}-\N{U+01f487}\N{U+01f4aa}\N{U+01f57a}\N{U+01f595}\N{U+01f596}\N{U+01f645}-\N{U+01f647}\N{U+01f64b}-\N{U+01f64f}\N{U+01f6a3}\N{U+01f6b4}-\N{U+01f6b6}\N{U+01f6c0}\N{U+01f6cc}\N{U+01f90f}\N{U+01f918}-\N{U+01f91c}\N{U+01f91e}\N{U+01f91f}\N{U+01f926}\N{U+01f930}-\N{U+01f939}\N{U+01f93d}\N{U+01f93e}\N{U+01f9b5}\N{U+01f9b6}\N{U+01f9b8}\N{U+01f9b9}\N{U+01f9bb}\N{U+01f9cd}-\N{U+01f9cf}\N{U+01f9d1}-\N{U+01f9dd}])[\N{U+01f3fb}-\N{U+01f3ff}]?|(?:\N{U+01f3f4}\N{U+0e0067}\N{U+0e0062}\N{U+0e0065}\N{U+0e006e}\N{U+0e0067}\N{U+0e007f}|\N{U+01f3f4}\N{U+0e0067}\N{U+0e0062}\N{U+0e0073}\N{U+0e0063}\N{U+0e0074}\N{U+0e007f}|\N{U+01f3f4}\N{U+0e0067}\N{U+0e0062}\N{U+0e0077}\N{U+0e006c}\N{U+0e0073}\N{U+0e007f}|\N{U+01f1e6}[\N{U+01f1e8}-\N{U+01f1ec}\N{U+01f1ee}\N{U+01f1f1}\N{U+01f1f2}\N{U+01f1f4}\N{U+01f1f6}-\N{U+01f1fa}\N{U+01f1fc}\N{U+01f1fd}\N{U+01f1ff}]|\N{U+01f1e7}[\N{U+01f1e6}\N{U+01f1e7}\N{U+01f1e9}-\N{U+01f1ef}\N{U+01f1f1}-\N{U+01f1f4}\N{U+01f1f6}-\N{U+01f1f9}\N{U+01f1fb}\N{U+01f1fc}\N{U+01f1fe}\N{U+01f1ff}]|\N{U+01f1e8}[\N{U+01f1e6}\N{U+01f1e8}\N{U+01f1e9}\N{U+01f1eb}-\N{U+01f1ee}\N{U+01f1f0}-\N{U+01f1f5}\N{U+01f1f7}\N{U+01f1fa}-\N{U+01f1ff}]|\N{U+01f1e9}[\N{U+01f1ea}\N{U+01f1ec}\N{U+01f1ef}\N{U+01f1f0}\N{U+01f1f2}\N{U+01f1f4}\N{U+01f1ff}]|\N{U+01f1ea}[\N{U+01f1e6}\N{U+01f1e8}\N{U+01f1ea}\N{U+01f1ec}\N{U+01f1ed}\N{U+01f1f7}-\N{U+01f1fa}]|\N{U+01f1eb}[\N{U+01f1ee}-\N{U+01f1f0}\N{U+01f1f2}\N{U+01f1f4}\N{U+01f1f7}]|\N{U+01f1ec}[\N{U+01f1e6}\N{U+01f1e7}\N{U+01f1e9}-\N{U+01f1ee}\N{U+01f1f1}-\N{U+01f1f3}\N{U+01f1f5}-\N{U+01f1fa}\N{U+01f1fc}\N{U+01f1fe}]|\N{U+01f1ed}[\N{U+01f1f0}\N{U+01f1f2}\N{U+01f1f3}\N{U+01f1f7}\N{U+01f1f9}\N{U+01f1fa}]|\N{U+01f1ee}[\N{U+01f1e8}-\N{U+01f1ea}\N{U+01f1f1}-\N{U+01f1f4}\N{U+01f1f6}-\N{U+01f1f9}]|\N{U+01f1ef}[\N{U+01f1ea}\N{U+01f1f2}\N{U+01f1f4}\N{U+01f1f5}]|\N{U+01f1f0}[\N{U+01f1ea}\N{U+01f1ec}-\N{U+01f1ee}\N{U+01f1f2}\N{U+01f1f3}\N{U+01f1f5}\N{U+01f1f7}\N{U+01f1fc}\N{U+01f1fe}\N{U+01f1ff}]|\N{U+01f1f1}[\N{U+01f1e6}-\N{U+01f1e8}\N{U+01f1ee}\N{U+01f1f0}\N{U+01f1f7}-\N{U+01f1fb}\N{U+01f1fe}]|\N{U+01f1f2}[\N{U+01f1e6}\N{U+01f1e8}-\N{U+01f1ed}\N{U+01f1f0}-\N{U+01f1ff}]|\N{U+01f1f3}[\N{U+01f1e6}\N{U+01f1e8}\N{U+01f1ea}-\N{U+01f1ec}\N{U+01f1ee}\N{U+01f1f1}\N{U+01f1f4}\N{U+01f1f5}\N{U+01f1f7}\N{U+01f1fa}\N{U+01f1ff}]|\N{U+01f1f4}\N{U+01f1f2}|\N{U+01f1f5}[\N{U+01f1e6}\N{U+01f1ea}-\N{U+01f1ed}\N{U+01f1f0}-\N{U+01f1f3}\N{U+01f1f7}-\N{U+01f1f9}\N{U+01f1fc}\N{U+01f1fe}]|\N{U+01f1f6}\N{U+01f1e6}|\N{U+01f1f7}[\N{U+01f1ea}\N{U+01f1f4}\N{U+01f1f8}\N{U+01f1fa}\N{U+01f1fc}]|\N{U+01f1f8}[\N{U+01f1e6}-\N{U+01f1ea}\N{U+01f1ec}-\N{U+01f1f4}\N{U+01f1f7}-\N{U+01f1f9}\N{U+01f1fb}\N{U+01f1fd}-\N{U+01f1ff}]|\N{U+01f1f9}[\N{U+01f1e6}\N{U+01f1e8}\N{U+01f1e9}\N{U+01f1eb}-\N{U+01f1ed}\N{U+01f1ef}-\N{U+01f1f4}\N{U+01f1f7}\N{U+01f1f9}\N{U+01f1fb}\N{U+01f1fc}\N{U+01f1ff}]|\N{U+01f1fa}[\N{U+01f1e6}\N{U+01f1ec}\N{U+01f1f2}\N{U+01f1f3}\N{U+01f1f8}\N{U+01f1fe}\N{U+01f1ff}]|\N{U+01f1fb}[\N{U+01f1e6}\N{U+01f1e8}\N{U+01f1ea}\N{U+01f1ec}\N{U+01f1ee}\N{U+01f1f3}\N{U+01f1fa}]|\N{U+01f1fc}[\N{U+01f1eb}\N{U+01f1f8}]|\N{U+01f1fd}\N{U+01f1f0}|\N{U+01f1fe}[\N{U+01f1ea}\N{U+01f1f9}]|\N{U+01f1ff}[\N{U+01f1e6}\N{U+01f1f2}\N{U+01f1fc}]|[\N{U+23e9}-\N{U+23ec}\N{U+23f0}\N{U+23f3}\N{U+267e}\N{U+26ce}\N{U+2705}\N{U+2728}\N{U+274c}\N{U+274e}\N{U+2753}-\N{U+2755}\N{U+2795}-\N{U+2797}\N{U+27b0}\N{U+27bf}\N{U+e50a}\N{U+01f0cf}\N{U+01f18e}\N{U+01f191}-\N{U+01f19a}\N{U+01f1e6}-\N{U+01f1ff}\N{U+01f201}\N{U+01f232}-\N{U+01f236}\N{U+01f238}-\N{U+01f23a}\N{U+01f250}\N{U+01f251}\N{U+01f300}-\N{U+01f320}\N{U+01f32d}-\N{U+01f335}\N{U+01f337}-\N{U+01f37c}\N{U+01f37e}-\N{U+01f384}\N{U+01f386}-\N{U+01f393}\N{U+01f3a0}-\N{U+01f3c1}\N{U+01f3c5}\N{U+01f3c6}\N{U+01f3c8}\N{U+01f3c9}\N{U+01f3cf}-\N{U+01f3d3}\N{U+01f3e0}-\N{U+01f3f0}\N{U+01f3f4}\N{U+01f3f8}-\N{U+01f43e}\N{U+01f440}\N{U+01f444}\N{U+01f445}\N{U+01f451}-\N{U+01f465}\N{U+01f46a}\N{U+01f46f}\N{U+01f479}-\N{U+01f47b}\N{U+01f47d}-\N{U+01f480}\N{U+01f484}\N{U+01f488}-\N{U+01f4a9}\N{U+01f4ab}-\N{U+01f4fc}\N{U+01f4ff}-\N{U+01f53d}\N{U+01f54b}-\N{U+01f54e}\N{U+01f550}-\N{U+01f567}\N{U+01f5a4}\N{U+01f5fb}-\N{U+01f644}\N{U+01f648}-\N{U+01f64a}\N{U+01f680}-\N{U+01f6a2}\N{U+01f6a4}-\N{U+01f6b3}\N{U+01f6b7}-\N{U+01f6bf}\N{U+01f6c1}-\N{U+01f6c5}\N{U+01f6d0}-\N{U+01f6d2}\N{U+01f6d5}\N{U+01f6eb}\N{U+01f6ec}\N{U+01f6f4}-\N{U+01f6fa}\N{U+01f7e0}-\N{U+01f7eb}\N{U+01f90d}\N{U+01f90e}\N{U+01f910}-\N{U+01f917}\N{U+01f91d}\N{U+01f920}-\N{U+01f925}\N{U+01f927}-\N{U+01f92f}\N{U+01f93a}\N{U+01f93c}\N{U+01f93f}-\N{U+01f945}\N{U+01f947}-\N{U+01f971}\N{U+01f973}-\N{U+01f976}\N{U+01f97a}-\N{U+01f9a2}\N{U+01f9a5}-\N{U+01f9aa}\N{U+01f9ae}-\N{U+01f9b4}\N{U+01f9b7}\N{U+01f9ba}\N{U+01f9bc}-\N{U+01f9ca}\N{U+01f9d0}\N{U+01f9de}-\N{U+01f9ff}\N{U+01fa70}-\N{U+01fa73}\N{U+01fa78}-\N{U+01fa7a}\N{U+01fa80}-\N{U+01fa82}\N{U+01fa90}-\N{U+01fa95}])|\N{U+fe0f}
/iox;

1;
