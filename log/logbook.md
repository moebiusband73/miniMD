<!-----------------------------------------------------------------------------
This document should be written based on the Github flavored markdown specs:
https://github.github.com/gfm/
It can be converted to html or pdf with pandoc:
pandoc -s -o logbook.html  -f gfm -t html logbook.md
pandoc test.txt -o test.pdf
or with the kramdown converter:
kramdown --template document  -i GFM  -o html logbook.md

Optional: Document how much time was spent. A simple python command line tool
for time tracking is [Watson](http://tailordev.github.io/Watson/).
------------------------------------------------------------------------------>

<!-----------------------------------------------------------------------------
The Agenda section is a scratchpad area for planning and Todo list
------------------------------------------------------------------------------>
# Agenda

Example for referencing an image:

![Plot title](figures/example.png "ALT Text")

<!-----------------------------------------------------------------------------
START BLOCK PREAMBLE -  Global information required in all steps: Add all
information required to build and benchmark the application. Should be extended
and maintained during the project.
------------------------------------------------------------------------------>
# Project Description

* Start date: 08/07/2019
* Home HPC center: Erlangen Regional Computing Center
* Contact HPC center:
   * Name: Jan Eitzinger
   * E-Mail: jan.eitzinger@fau.de

<!-----------------------------------------------------------------------------
Formulate a clear and specific performance target
------------------------------------------------------------------------------>
## Target

## Application Info

* Name: Mantevo MiniMD
* Domain: Molecular dynamic application proxy
* Version: Based on reference version 1.2
* URL: https://mantevo.github.io/download.html

<!-----------------------------------------------------------------------------
All steps required to build the software including dependencies
------------------------------------------------------------------------------>
## How to build software

* Edit Makefile and set toolchain with the `TAG` variable
* Edit toolchain settings in the  make include file (e.g. `include_ICC.mk` )
* Call `make` to build. `make clean` to remove intermediate build results and
  `make distclean` to remove all build files. To output all commands set `Q` 
  to empty, e.g. `make Q=`

<!-----------------------------------------------------------------------------
Describe in detail how to configure and setup the testcases(es)
------------------------------------------------------------------------------>
## Testcase description

Detailed description about the options and input files are available in
the original `README-original`. For benchmarking the double precision (default)
version was used build with MPI only. Only the default lennard jones force
calculation was considered using two variants:
* `compute_halfneigh`: Forces are also written back to neighbouring atom.
* `compute_fullheigh`: Forces are not written back. More algorithmic work but
  simpler to parallize and vectorize.


<!-----------------------------------------------------------------------------
All steps required to run the testcase and control affinity for application
------------------------------------------------------------------------------>
## How to run software

To run with default testcase:
```
$cd data
$../miniMD-ICC
```

To get available command line options call with:
```
$../miniMD-ICC -h

```

Important options used are:
```
--half_neigh <int>:           use half neighborlists (default 1)
        0: full neighborlist
        1: half neighborlist
       -1: original miniMD half neighborlist force (not OpenMP safe)
-n / --nsteps <int>:          set number of timesteps for simulation
```

<!-----------------------------------------------------------------------------
END BLOCK PREAMBLE
------------------------------------------------------------------------------>

<!-----------------------------------------------------------------------------
START BLOCK ANALYST - This block is required for any new analyst taking over
the project. Give every activity a unique integer tag starting from 1.
------------------------------------------------------------------------------>
# Transfer to Analyst: JE

* Start date: 08/07/2019
* Contact HPC center: Erlangen Regional Computing Center
   * Name: Jan Eitzinger
   * E-Mail: jan.eitzinger@fau.de

<!-----------------------------------------------------------------------------
START BLOCK BENCHMARKING - Run helper script machine-state.sh and store results
in directory session-<ID> named <hostname>.txt. Document everything that you
consider to be relevant for performance.
------------------------------------------------------------------------------>
## Benchmarking JE-B-1

### Testsystem

* Host/Clustername: RRZE test cluster
* Cluster Info URL: no web page
* CPU type: Intel(R) Xeon(R) Platinum 8260L CPU @ 2.40GHz (CascadeLake SP)
* Memory capacity: 197GB
* Number of cores per socket: 24 
* Interconnect: no high speed interconnect

### Software Environment

**Compiler**:
* Vendor: Intel
* Version: icpc (ICC) 19.0.2.187 20190117

**OS**:
* Distribution: Ubuntu
* Version: 18.04.2 LTS
* Kernel version: Linux 4.15.0-51-generic 

<!-----------------------------------------------------------------------------
Create a runtime profile. Which tool was used? How was the profile created.
Describe and discuss the runtime profile.
------------------------------------------------------------------------------>
## Runtime Profile JE-RP-2

<!-----------------------------------------------------------------------------
Perform a static code review.
------------------------------------------------------------------------------>
## Code Review JE-CR-3

The algorithm is as follows:
* Loop over all local atoms
* Compute position of atom i
* Get neighnour list and loop over all neighbours
* Compute distance of neighbour atom j
* If atom i is within cutoff radius of atom i:
* Compute force and add up force to total force vector scaled with distance
* After all neighbours are traversed add up force vector to force vector
  of atom i.

The difference between `halfneigh` and `fullneigh` is that with `halfneigh` the
inverse force is at once written back to the neighbour atom, while in `fullneigh`
the force is only added to the local atom. `halfneigh` saves work but writes
erratically in the atom force array.

This are the loops for `compute_fullneigh`:
``` c++
for(int i = 0; i < nlocal; i++) {
    neighs = &neighbor.neighbors[i * neighbor.maxneighs];
    const int numneighs = neighbor.numneigh[i];
    const MMD_float xtmp = x[i * PAD + 0];
    const MMD_float ytmp = x[i * PAD + 1];
    const MMD_float ztmp = x[i * PAD + 2];

    MMD_float fix = 0;
    MMD_float fiy = 0;
    MMD_float fiz = 0;

    for(int k = 0; k < numneighs; k++) {
        const int j = neighs[k];
        const MMD_float delx = xtmp - x[j * PAD + 0];
        const MMD_float dely = ytmp - x[j * PAD + 1];
        const MMD_float delz = ztmp - x[j * PAD + 2];
        const MMD_float rsq = delx * delx + dely * dely + delz * delz;

        if(rsq < cutforcesq) {
            const MMD_float sr2 = 1.0 / rsq;
            const MMD_float sr6 = sr2 * sr2 * sr2 * sigma6;
            const MMD_float force = 48.0 * sr6 * (sr6 - 0.5) * sr2 * epsilon;

            fix += delx * force;
            fiy += dely * force;
            fiz += delz * force;
        }
    }

    f[i * PAD + 0] += fix;
    f[i * PAD + 1] += fiy;
    f[i * PAD + 2] += fiz;
}
```

The atom position components are stored in array of structure data layout.
The data access on the neighbour positions in the neighbour list are potentially 
erratic (loaded from the `neighs[k]` array). Also the actual force calculation
is within an if condition. This makes this loop not trivial to vectorize.

<!-----------------------------------------------------------------------------
Application benchmarking runs. What experiment was done? Add results or
reference plots in directory session-<NAME-TAG>-<ID>. Number all sections
consecutivley such that every section has a unique ID.
------------------------------------------------------------------------------>
## Result JE-R-4

### Problem: <DESCRIPTION>


### Measurement JE-M-5

Scaling run with AVX512 on CascadeLake with 24 core per socket and fixed frequency of   2.4 GHz:

| NP | runtime |
|----|---------|
| 1  |  19.77  |
| 2  |  10.01  |
| 4  |  5.020  |
| 6  |  3.373  |
| 8  |  2.522  |
| 10 |  2.061  |
| 12 |  1.703  |
| 14 |  1.503  |
| 16 |  1.289  |
| 18 |  1.166  |
| 20 |  1.058  |
| 22 |  0.984  |
| 24 |  0.891  |

```
Verbatim Text
```

<!-----------------------------------------------------------------------------
Document the initial performance which serves as baseline for further progress
and is used to compute the achieved speedup. Document exactly how the baseline
was created.
------------------------------------------------------------------------------>
## Baseline

* Time to solution:
* Performance:


<!-----------------------------------------------------------------------------
Explain which tool was used and how the measurements were done. Store and
reference the results. If applicable discuss and explain profiles.
------------------------------------------------------------------------------>
## Performance Profile <NAME-TAG>-<ID>.2

<!-----------------------------------------------------------------------------
Analysis and insights extracted from benchmarking results. Planning of more 
benchmarks.
------------------------------------------------------------------------------>
## Analysis <NAME-TAG>-<ID>.3


<!-----------------------------------------------------------------------------
Document all changes with  filepath:linenumber and explanation what was changed
and why. Create patch if applicable and store patch in referenced file.
------------------------------------------------------------------------------>
## Optimisation <NAME-TAG>-<ID>.4: <DESCRIPTION>


<!-----------------------------------------------------------------------------
END BLOCK BENCHMARKING
------------------------------------------------------------------------------>

<!-----------------------------------------------------------------------------
Wrap up the final result and discuss the speedup.
Optional: Document how much time was spent. A simple python command line tool
for time tracking is [Watson](http://tailordev.github.io/Watson/).
------------------------------------------------------------------------------>
## Summary

* Time to solution:
* Performance:
* Speedup:

## Effort

* Time spent:

<!-----------------------------------------------------------------------------
END BLOCK ANALYST
------------------------------------------------------------------------------>

<!-----------------------------------------------------------------------------
START BLOCK SUMMARY - This block is only required if multiple analysts worked
on the project.
------------------------------------------------------------------------------>
# Overall Summary

* End date: DD/MM/YYYY

## Total Effort

* Total time spent:
* Estimated core hours saved:

<!-----------------------------------------------------------------------------
END BLOCK SUMMARY
------------------------------------------------------------------------------>
