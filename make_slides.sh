#!/bin/bash

  OUTPUTDIR=o

  SVG=slides.svg
  MASTERNAME=`basename $SVG | cut -d "." -f 1`


  INCLUDEALWAYS="AA|SRC"
# --------------------------------------------------------------------------- #
# MAKE GREP PATTERN FOR LAYERS TO INCLUDE ALWAYS
# --------------------------------------------------------------------------- #
  NAMESTART="label=\""
  for TYPE in `echo $INCLUDEALWAYS | sed 's/|/\n/g'`
   do
      PERMALAYERS=$PERMALAYERS`echo $TYPE | \
                  sed "s/^/$NAMESTART/g" | \
                  sed 's/$/|/g'`
  done 
      PERMALAYERS=`echo $PERMALAYERS | sed 's/|$//g'`

# --------------------------------------------------------------------------- #
# STRUCTURE SVG BODY FOR EASIER PARSING (ONE LAYER PER LINE)
# --------------------------------------------------------------------------- #

      sed 's/ / \n/g' $SVG | \
      sed '/^.$/d' | \
      sed -n '/<\/metadata>/,/<\/svg>/p' | sed '1d;$d' | \
      sed ':a;N;$!ba;s/\n/ /g' | \
      sed 's/<\/g>/\n<\/g>/g' | \
      sed 's/\/>/\n\/>\n/g' | \
      sed 's/\(<g.*inkscape:groupmode="layer"[^"]*"\)/QWERTZUIOP\1/g' | \
      sed ':a;N;$!ba;s/\n/ /g' | \
      sed 's/QWERTZUIOP/\n\n\n\n/g' | \
      sed 's/display:none/display:inline/g' > ${SVG%%.*}.tmp

  SVGHEADER=`tac $SVG | sed -n '/<\/metadata>/,$p' | tac`


# --------------------------------------------------------------------------- #
# WRITE PNG FOR EACH LAYER (+ PERMANENT LAYERS)
# --------------------------------------------------------------------------- #
  CNT=1
  for LAYERNAME in `cat ${SVG%%.*}.tmp | \
                    sed "s/$NAMESTART/\n$NAMESTART/g" | \
                    grep label | \
                    cut -d "\"" -f 2 | \
                    grep -v "XX" | \
                    egrep -v $INCLUDEALWAYS`
   do
      LSVG=${LAYERNAME}.svg
      echo $SVGHEADER                      >  $LSVG
      egrep $INCLUDEALWAYS ${SVG%%.*}.tmp  >> $LSVG
      grep $LAYERNAME ${SVG%%.*}.tmp       >> $LSVG
      echo "</svg>"                        >> $LSVG

      inkscape --export-png=${OUTPUTDIR}/${LSVG%%.*}.png $LSVG
      rm $LSVG


  done


  rm ${SVG%%.*}.tmp





















exit 0;
