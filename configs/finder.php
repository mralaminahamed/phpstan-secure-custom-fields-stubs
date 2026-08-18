<?php

return \StubsGenerator\Finder::create()
    ->in( array(
        'source/secure-custom-fields',
    ) )
    ->notPath( 'tests' )
    ->notPath( 'lang' )
    ->notPath( 'assets' )
    ->sortByName( true )
;
