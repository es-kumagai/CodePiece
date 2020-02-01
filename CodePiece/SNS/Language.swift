//
//  Language.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/20.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

extension PopularLanguage {
	
	var hashtag: Hashtag {

		return language.hashtag
	}
}

extension Language {

	var hashtag: Hashtag {
		
		switch self {
			
		case .actionScript:
			return "actionscript"
			
		case .c:
			return "C"
			
		case .cSharp:
			return "csharp"
			
		case .cPlusPlus:
			return "cpp"
			
		case .clojure:
			return "clojure"
			
		case .coffeeScript:
			return "coffee"
			
		case .css:
			return "css"
			
		case .go:
			return "go"
			
		case .haskell:
			return "haskell"
			
		case .html:
			return "html"
			
		case .java:
			return "java"
			
		case .javaScript:
			return "javascript"
			
		case .lua:
			return "lua"

		case .matlab:
			return "matlab"
			
		case .objectiveC:
			return "objc"
			
		case .perl:
			return "perl"
			
		case .php:
			return "php"
			
		case .python:
			return "python"
			
		case .r:
			return "r"
			
		case .ruby:
			return "ruby"
			
		case .scala:
			return "scala"
			
		case .shell:
			return "sh"
			
		case .swift:
			return "swift"
			
		case .tex:
			return "tex"
			
		case .vimL:
			return "vim"
			
		case .abap:
			return "abap"
			
		case .ada:
			return "adb"
			
		case .agda:
			return "agda"
			
		case .agsScript:
			return "agsscript"
			
		case .alloy:
			return "alloy"
			
		case .ampl:
			return "ampl"
			
		case .antBuildSystem:
			return "ant"
			
		case .antlr:
			return "antlr"
			
		case .apacheConf:
			return "apacheconf"
			
		case .apex:
			return "apex"
			
		case .apl:
			return "apl"
			
		case .appleScript:
			return "applescript"
			
		case .arc:
			return "arc"
			
		case .arduino:
			return "arduino"
			
		case .asciiDoc:
			return "asciidoc"
			
		case .asp:
			return "asp"
			
		case .aspectJ:
			return "aspectj"
			
		case .assembly:
			return "asm"
			
		case .ats:
			return "ats"
			
		case .augeas:
			return "augeas"
			
		case .autoHotkey:
			return "autohotkey"
			
		case .autoIt:
			return "autoit"
			
		case .awk:
			return "awk"
			
		case .batchfile:
			return "bat"
			
		case .befunge:
			return "befunge"
			
		case .bison:
			return "bison"
			
		case .bitBake:
			return "bitbake"
			
		case .blitzBasic:
			return "blitzbasic"
			
		case .blitzMax:
			return "blitzmax"
			
		case .bluespec:
			return "bluespec"
			
		case .boo:
			return "boo"
			
		case .brainfuck:
			return "brainfuck"
			
		case .brightscript:
			return "brightscript"
			
		case .bro:
			return "bro"
			
		case .cObjDump:
			return "c_objdump"
			
//		case C2hs_Haskell = "C2hs Haskell"
//		case Cap_n_Proto = "Cap'n Proto"
//		case CartoCSS
//		case Ceylon
//		case Chapel
//		case ChucK
//		case Cirru
//		case Clean
//		case CLIPS
//		case CMake
//		case COBOL
//		case ColdFusion
//		case ColdFusion_CFC = "ColdFusion CFC"
//		case Common_Lisp = "Common Lisp"
//		case Component_Pascal = "Component Pascal"
//		case Cool
//		case Coq
//		case Cpp_ObjDump = "Cpp-ObjDump"
//		case Creole
//		case Crystal
//		case Cucumber
//		case Cuda
//		case Cycript
//		case Cython
//		case D
//		case D_ObjDump = "D-ObjDump"
//		case Darcs_Patch = "Darcs Patch"
//		case Dart
//		case desktop
//		case Diff
//		case DM
//		case Dockerfile
//		case Dogescript
//		case DTrace
//		case Dylan
//		case E
//		case Eagle
//		case eC
//		case Ecere_Projects = "Ecere Projects"
//		case ECL
//		case edn
//		case Eiffel
//		case Elixir
//		case Elm
//		case Emacs_Lisp = "Emacs Lisp"
//		case EmberScript
//		case Erlang
//		case FSharp = "F#"
//		case Factor
//		case Fancy
//		case Fantom
//		case fish
//		case FLUX
//		case Formatted
//		case Forth
//		case FORTRAN
//		case Frege
//		case G_code = "G-code"
//		case Game_Maker_Language = "Game Maker Language"
//		case GAMS
//		case GAP
//		case GAS
//		case GDScript
//		case Genshi
//		case Gentoo_Ebuild = "Gentoo Ebuild"
//		case Gentoo_Eclass = "Gentoo Eclass"
//		case Gettext_Catalog = "Gettext Catalog"
//		case GLSL
//		case Glyph
//		case Gnuplot
//		case Golo
//		case Gosu
//		case Grace
//		case Gradle
//		case Grammatical_Framework = "Grammatical Framework"
//		case Graph_Modeling_Language = "Graph Modeling Language"
//		case Graphviz__DOT_ = "Graphviz (DOT)"
//		case Groff
//		case Groovy
//		case Groovy_Server_Pages = "Groovy Server Pages"
//		case Hack
//		case Haml
//		case Handlebars
//		case Harbour
//		case Haxe
//		case HTML_Django = "HTML+Django"
//		case HTML_ERB = "HTML+ERB"
//		case HTML_PHP = "HTML+PHP"
//		case HTTP
//		case Hy
//		case IDL
//		case Idris
//		case IGOR_Pro = "IGOR Pro"
//		case Inform_7 = "Inform 7"
//		case INI
//		case Inno_Setup = "Inno Setup"
//		case Io
//		case Ioke
//		case IRC_log = "IRC log"
//		case Isabelle
//		case J
//		case Jade
//		case Jasmin
//		case Java_Server_Pages = "Java Server Pages"
//		case JSON
//		case JSON5
//		case JSONiq
//		case JSONLD
//		case Julia
//		case Kit
		case .kotlin:
			return "kotlin"
			
//		case KRL
//		case LabVIEW
//		case Lasso
//		case Latte
//		case Lean
//		case Less
//		case LFE
//		case LilyPond
//		case Liquid
//		case Literate_Agda = "Literate Agda"
//		case Literate_CoffeeScript = "Literate CoffeeScript"
//		case Literate_Haskell = "Literate Haskell"
//		case LiveScript
//		case LLVM
//		case Logos
//		case Logtalk
//		case LOLCODE
//		case LookML
//		case LoomScript
//		case LSL
//		case M
//		case Makefile
//		case Mako
//		case Markdown
//		case Mask
//		case Mathematica
//		case Maven_POM = "Maven POM"
//		case Max
//		case MediaWiki
//		case Mercury
//		case MiniD
//		case Mirah
//		case Modelica
//		case Monkey
//		case Moocode
//		case MoonScript
//		case MTML
//		case MUF
//		case mupad
//		case Myghty
//		case Nemerle
//		case nesC
//		case NetLogo
//		case NewLisp
//		case Nginx
//		case Nimrod
//		case Ninja
//		case Nit
//		case Nix
//		case NL
//		case NSIS
//		case Nu
//		case NumPy
//		case ObjDump
//		case Objective_CPlusPlus = "Objective-C++"
//		case Objective_J = "Objective-J"
//		case OCaml
//		case Omgrofl
//		case ooc
//		case Opa
//		case Opal
//		case OpenCL
//		case OpenEdge_ABL = "OpenEdge ABL"
//		case OpenSCAD
//		case Org
//		case Ox
//		case Oxygene
//		case Oz
//		case Pan
//		case Papyrus
//		case Parrot
//		case Parrot_Assembly = "Parrot Assembly"
//		case Parrot_Internal_Representation = "Parrot Internal Representation"
//		case Pascal
//		case PAWN
//		case Perl6
//		case PigLatin
//		case Pike
//		case PLpgSQL
//		case PLSQL
//		case Pod
//		case PogoScript
//		case PostScript
//		case PowerShell
//		case Processing
//		case Prolog
//		case Propeller_Spin = "Propeller Spin"
//		case Protocol_Buffer = "Protocol Buffer"
//		case Public_Key = "Public Key"
//		case Puppet
//		case Pure_Data = "Pure Data"
//		case PureBasic
//		case PureScript
//		case Python_traceback = "Python traceback"
//		case QMake
//		case QML
//		case Racket
//		case Ragel_in_Ruby_Host = "Ragel in Ruby Host"
//		case RAML
//		case Raw_token_data = "Raw token data"
//		case RDoc
//		case REALbasic
//		case Rebol
//		case Red
//		case Redcode
//		case reStructuredText
//		case RHTML
//		case RMarkdown
//		case RobotFramework
//		case Rouge
//		case Rust
//		case Sage
//		case SaltStack
//		case SAS
//		case Sass
//		case Scaml
//		case Scheme
//		case Scilab
//		case SCSS
//		case Self_ = "Self"
//		case ShellSession
//		case Shen
//		case Slash
//		case Slim
//		case Smalltalk
//		case Smarty
//		case SourcePawn
//		case SPARQL
//		case SQF
//		case SQL
//		case SQLPL
//		case Squirrel
//		case Standard_ML = "Standard ML"
//		case Stata
//		case STON
//		case Stylus
//		case SuperCollider
//		case SVG
//		case SystemVerilog
//		case Tcl
//		case Tcsh
//		case Tea
		case .text:
			return "text"
//
//		case Textile
//		case Thrift
//		case TOML
//		case Turing
//		case Turtle
//		case Twig
//		case TXL
//		case TypeScript
//		case Unified_Parallel_C = "Unified Parallel C"
//		case UnrealScript
//		case Vala
//		case VCL
//		case Verilog
//		case VHDL
//		case Visual_Basic = "Visual Basic"
//		case Volt
//		case Web_Ontology_Language = "Web Ontology Language"
//		case WebIDL
//		case wisp
//		case xBase
//		case XC
//		case XML
//		case Xojo
//		case XProc
//		case XQuery
//		case XS
//		case XSLT
//		case Xtend
//		case YAML
//		case Zephir
//		case Zimpl
		}
	}
}
