About this project
==================

This project shows several source element types of the standard transformation in action.
The resulting source code may be compiled and the generated documentation be viewed
in a HTML viewer. For more information on standard transformation, see the "pure::variants
User's Guide" in section "Standard Transformation".


Initial configuration
=====================

Open "Variant Project" View and open "Config" properties (context menu). Select item
"Configuration Space" and go to page "Input-Output". Check the shown paths and change them
into valid values if necessary.

No further configuration is required.


The Example in Detail
=====================

This example demonstrates the use of some source element types in conjunction with the
standard transformation.

The component "Build" of family model "System.ccfm" contains two source element types:
ps:makefile and ps:fragment. For the first, there is a tutorial on how to use it, see
http://www.pure-systems.com to access tutorials. For the second one there is another
example named "Fragment Example". In the "Flags" component a flag file is generated
using ps:flagfile. There is a tutorial for flag files, too. For ps:condxml type as in
component "Documentation" we refer to the "Conditional Documents" example.


Transformation results
======================

The transformation result will be stored in <Project>/GenSystem/ (or what ever path
was specified in the config space properties). During transformation classes and a
makefile as well as documentation files are generated from input files.