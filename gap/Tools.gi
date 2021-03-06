#############################################################################
##
##  Tools.gi                                               D-Modules package
##
##  Copyright 2010-2011, Mohamed Barakat, University of Kaiserslautern
##
##  Implementations of tool procedures.
##
#############################################################################

####################################
#
# global variables:
#
####################################

HOMALG_IO.Pictograms.ApplyToSection := "sec";
HOMALG_IO.Pictograms.SolutionOfSystem := "sol";
HOMALG_IO.Pictograms.NumeratorOfDifferentialAction := "tot";
HOMALG_IO.Pictograms.IntersectWithSubalgebra := "InS";

####################################
#
# methods for operations:
#
####################################

##
InstallMethod( UnorderedTuplesRespectingOrder,
        "for a list",
        [ IsList, IsInt ],
        
  function( L, o )
    local l, M;
    
    if o <= 0 then
        return [ [ ] ];
    elif o = 1 then
        return List( L, a -> [ a ] );
    fi;
    
    l := Length( L );
    
    M := List( [ 1 .. l ],
               i -> UnorderedTuplesRespectingOrder( L{[ i .. l ]}, o - 1 ) );
    
    M := List( [ 1 .. l ],
               i -> List( M[i], r -> Concatenation( [ L[i] ], r ) ) );
    
    return Concatenation( M );
    
end );

##
InstallMethod( ApplyToSection,
        "for two homalg matrices",
        [ IsHomalgMatrix, IsHomalgMatrix ],
        
  function( mat, u )
    local R, r, RP, sec;
    
    R := HomalgRing( mat );
    
    r := NrRows( mat );
    
    if r = 0 then
        return HomalgZeroMatrix( r, 1, R );
    fi;
    
    RP := homalgTable( R );
    
    if not IsBound( RP!.ApplyToSection ) then
        Error( "could not find a procedure called ApplyToSection in the homalgTable of the ring\n" );
    fi;
    
    sec := RP!.ApplyToSection( mat, u );	## the external object
    
    return HomalgMatrix( sec, r, 1, R );
    
end );

##
InstallMethod( SolutionOfSystem,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( sys )
    local R, RP, c, sol, rel, solver;
    
    R := HomalgRing( sys );
    
    RP := homalgTable( R );
    
    if not IsBound( RP!.SolutionOfSystem ) then
        Error( "could not find a procedure called SolutionOfSystem in the homalgTable of the ring\n" );
    fi;
    
    if not IsBound( sys!.section ) then
        Error( "missing section\n" );
    fi;
    
    c := NrRows( sys!.section );
    
    sol := RP!.SolutionOfSystem( sys );	## the external object
    
    if IsBound( sol!.Relations ) then
        
        rel := sol!.Relations;
        Unbind( sol!.Relations );	## will bind it to the output matrix below
        
        solver := sol!.solver;
        
    fi;
    
    sol := HomalgMatrix( sol, c, 1, R );
    
    ## store any relations in the solution matrix
    if IsBound( rel ) then
        sol!.Relations := rel;
    fi;
    
    return sol;
    
end );

##
InstallMethod( NumeratorOfDifferentialAction,
        "for strings",
        [ IsList, IsString, IsString, IsString, IsHomalgRing ],
        
  function( monomial, numer, denom, arguments, R )
    local RP, tot;
    
    RP := homalgTable( R );
    
    if not IsBound( RP!.NumeratorOfDifferentialAction ) then
        Error( "could not find a procedure called NumeratorOfDifferentialAction in the homalgTable of the ring\n" );
    fi;
    
    tot := RP!.NumeratorOfDifferentialAction( monomial, numer, denom, arguments, R );
    
    tot := HomalgRingElement( tot, R );
    
    return tot;
    
end );

##
InstallMethod( NumeratorOfDifferentialAction,
        "for strings",
        [ IsInt, IsString, IsString, IsString, IsHomalgRing ],
        
  function( order, section, arguments, multiplier, R )
    local RP, tot;
    
    RP := homalgTable( R );
    
    if not IsBound( RP!.NumeratorOfDifferentialActionByOrder ) then
        Error( "could not find a procedure called NumeratorOfDifferentialActionByOrder in the homalgTable of the ring\n" );
    fi;
    
    tot := RP!.NumeratorOfDifferentialActionByOrder( order, section, arguments, multiplier, R );
    
    return tot;
    
end );

##
InstallMethod( IntersectWithSubalgebra,
        "for a module and a homalg ring element",
        [ IsFinitelyPresentedSubmoduleRep, IsHomalgRingElement ],
        
  function( I, s )
    local R, RP, i, b;
    
    R := HomalgRing( I );
    
    RP := homalgTable( R );
    
    if not IsBound( RP!.IntersectWithSubalgebra ) then
        Error( "could not find a procedure called IntersectWithSubalgebra in the homalgTable of the ring\n" );
    fi;
    
    i := MatrixOfGenerators( I );
    
    if IsHomalgLeftObjectOrMorphismOfLeftObjects( I ) then
        #i := BasisOfRows( i );
    else
        #i := BasisOfColumns( i );
    fi;
    
    b := HomalgRingElement( RP!.IntersectWithSubalgebra( i, s ), R );
    
    return b;
    
end );

##
InstallMethod( IntersectWithSubalgebra,
        "for a module and a string",
        [ IsFinitelyPresentedSubmoduleRep, IsString ],
        
  function( I, s )
    
    return IntersectWithSubalgebra( I, s / HomalgRing( I ) );
    
end );

##
InstallMethod( IntersectWithSubalgebra,
        "for a module and a string",
        [ IsFinitelyPresentedSubmoduleRep, IsPolynomial ],
        
  function( I, s )
    
    s := IndeterminateName( FamilyObj( s ),
                 IndeterminateNumberOfUnivariateRationalFunction( s ) );
    
    return IntersectWithSubalgebra( I, s );
    
end );
