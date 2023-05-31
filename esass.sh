###=== Basic steps for eROSITA data extraction, written by Lin He in 2023 ===================
###=== USAGE: Set the process = 1 and run bash esass.sh in your terminal for each step. =====
###==========================================================================================

# eFEDs field that your target falls in.
field="07"

image=0
exp=0
soudet=0
spec=1


if [ $image = 1 ]
then 
    for fid in $field
    do
        echo "filter energy and generate the counts map" 
        evtool eventfiles="fm00_3000${fid}_020_EventList_c001.fits" outfile="eFEDs_${fid}_counts.fits" image=yes size="auto" emin=0.2 emax=5.0 clobber=yes
    done
fi


if [ $exp = 1 ]
then 
    for fid in $field
    do
    echo "create the exposure map"
    expmap inputdatasets="eFEDs_${fid}_counts.fits" emin=0.2 emax=5.0 templateimage="eFEDs_${fid}_counts.fits" mergedmaps="eFEDs_${fid}_exp.fits"
    done
fi


if [ $soudet = 1 ]
then
	for fid in $field
	do
		echo "Run detection mask"
		rm *eFEDS${fid}_detmask.fits*
		ermask expimage="eFEDs_${fid}_exp.fits" detmask="eFEDS${fid}_detmask.fits"

		echo "Run erbox in local mode"
		erbox images="eFEDs_${fid}_counts.fits" boxlist="boxlist_local.fits" emin=200 emax=5000 expimages="eFEDs_${fid}_exp.fits" detmasks="eFEDS${fid}_detmask.fits" bkgima_flag=N ecf=1

		echo "Run erbackmap"
		erbackmap image="eFEDs_${fid}_counts.fits" expimage="eFEDs_${fid}_exp.fits" boxlist="boxlist_local.fits" detmask="eFEDS${fid}_detmask.fits" bkgimage="eFEDS${fid}_backmap.fits" emin=200 emax=5000 cheesemask="cheesemask_eFEDS${fid}.fits"

		echo "Run erbox in map mode"
		erbox images="eFEDs_${fid}_counts.fits" boxlist="boxlist_local.fits" expimages="eFEDs_${fid}_exp.fits" detmasks="eFEDS${fid}_detmask.fits" bkgimages="eFEDS${fid}_backmap.fits" emin=200 emax=5000 ecf=1

		echo "Run ermldet in"
		ermldet mllist="eFEDS${fid}_mllist.fits" boxlist="boxlist_local.fits" images="eFEDs_${fid}_counts.fits" expimages="eFEDs_${fid}_exp.fits" detmasks="eFEDS${fid}_detmask.fits" bkgimages="eFEDS${fid}_backmap.fits" extentmodel=beta srcimages="sourceimage_${fid}.fits" emin=200 emax=5000

		echo "Run catprep in"
		catprep infile="eFEDS${fid}_mllist.fits" outfile="eFEDS${fid}_catalog.fits"
	done
fi


if [ $spec = 1 ]
then 
    for fid in $field
    do	
    echo "extract the spectra"
    srctool eventfiles="fm00_3000${fid}_020_EventList_c001.fits"\
    srccoord="fk5;8:38:09.2921,+2:30:41.735"\
    prefix="src1/src1_"\
    todo="SPEC ARF RMF LC LCCORR"\
    insts="1 2 3 4 5 6 7"\
    srcreg='fk5;circle 8:38:09.2921,+2:30:41.735,60"'\
    backreg='fk5;annulus 8:38:09.2921,+2:30:41.735,110",140"'\
    exttype="POINT"\
	lcpars="500.0" \
    lcemin="0.5 2.0" \
    lcemax="2.0 10.0" \
    lcgamma="1.7" \
    clobber="yes"
    done
fi
