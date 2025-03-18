#!/bin/bash

rm -rf PE*
rm fort.6*
rm max*
rm min*
rm metis_graph.txt
rm partmesh.txt
rm swan_*

adcprep --np 8 --partmesh
adcprep --np 8 --prepall
mpirun -np 8 ~/adcirc/work/padcirc

rm -rf PE*
