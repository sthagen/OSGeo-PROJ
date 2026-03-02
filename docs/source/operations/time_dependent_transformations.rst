.. _time_dependent_transformations:

================================================================================
Time-dependent transformations
================================================================================

Introduction
------------

PROJ offers several coordinate operation methods that can deal with time-dependent
transformations:

* 15-parameter :ref:`Helmert <helmert>` operation, with the translation rates
  (``dx``, ``dy``, ``dz``), the scale rate (``dz``),
  the rotation rates (``drx``, ``dry``, ``drz``) and the central epoch of
  transformation (``t_epoch``). Such transformations are typically used between
  a static CRS (bound to a tectonic plate) and a dynamic CRS (such as one of the
  ITRF or WGS 84 realizations).

  To transform Sydney coordinates at epoch 2026.0 from ITRF2014 to GDA2020,
  you can use for example:

  ::

        echo -33.8623 151.2077 0 2026 | cs2cs -d 8 ITRF2014 GDA2020

        -33.86230294 151.20769882 0.00101330 2026


  or equivalently using the PROJ pipeline returned by ``projinfo ITRF2014 GDA2020``:

  ::

        echo -33.8623 151.2077 0 2026 | cct -d 8 \
          +proj=pipeline \
          +step +proj=axisswap +order=2,1 \
          +step +proj=unitconvert +xy_in=deg +xy_out=rad \
          +step +proj=cart +ellps=GRS80 \
          +step +proj=helmert +x=0 +y=0 +z=0 +rx=0 +ry=0 +rz=0 +s=0 +dx=0 +dy=0 +dz=0 \
                +drx=0.00150379 +dry=0.00118346 +drz=0.00120716 +ds=0 +t_epoch=2020 \
                +convention=coordinate_frame \
          +step +inv +proj=cart +ellps=GRS80 \
          +step +proj=unitconvert +xy_in=rad +xy_out=deg \
          +step +proj=axisswap +order=2,1

        -33.86230294    151.20769882    0.00101330     2026.0000


  and the reverse transformation:

  ::

        echo -33.86230294 151.20769882 0.00101330 2026 | cs2cs -d 8 GDA2020 ITRF2014

        -33.86230000 151.20770000 0.00000002 2026

  Note that in the reverse transformation the epoch is also specified as seemingly
  being an input information, whereas it is the target epoch for ITRF2014. This
  is an historic PROJ behavior before the introduction of a more generic framework
  to deal with coordinate epochs. Since PROJ 9.4, you can also qualify a dynamic
  CRS with a coordinate epoch using the syntax "<CRS name>@<epoch>" or "<CRS code>@<epoch>"

  For example, re-using above use cases 

  ::

        echo -33.8623 151.2077 | cs2cs -d 8 ITRF2014@2026.0 GDA2020

        -33.86230294 151.20769882 0.00101330

  ::

        echo -33.86230294 151.20769882 0.00101330 | cs2cs -d 8 EPSG:7844 EPSG:9000@2026.0

        -33.86230000 151.20770000 0.00000002


* Point motion operation between two epochs of a dynamic CRS using a velocity grid-based
  transformation, with the :ref:`deformation` operator.

  For example, to transform coordinates in NAD83(CSRS)v7 CRS from epoch 2010.0 to epoch 2002.0

  ::

        echo 60 -100 0 | PROJ_NETWORK=ON cs2cs -d 8 "NAD83(CSRS)v7 @ 2010.0" "NAD83(CSRS)v7 @ 2002.0"

        60.00000011 -100.00000045 -0.06764700

  or equivalently using the PROJ pipeline returned by
  ``projinfo "NAD83(CSRS)v7 @ 2010.0" "NAD83(CSRS)v7 @ 2002.0" --spatial-test intersects``
  
  ::

        echo 60 -100 0 | PROJ_NETWORK=ON  cct -d 8 \
          +proj=pipeline \
          +step +proj=set +v_4=2010 \
          +step +proj=axisswap +order=2,1 \
          +step +proj=unitconvert +xy_in=deg +z_in=m +xy_out=rad +z_out=m \
          +step +proj=cart +ellps=GRS80 \
          +step +proj=set +v_4=2010 +omit_fwd \
          +step +proj=deformation +dt=-8 +grids=ca_nrc_NAD83v70VG.tif +ellps=GRS80 \
          +step +proj=set +v_4=2002 +omit_inv \
          +step +inv +proj=cart +ellps=GRS80 \
          +step +proj=unitconvert +xy_in=rad +xy_out=deg \
          +step +proj=axisswap +order=2,1 \
          +step +proj=set +v_4=2002

        60.00000011 -100.00000045 -0.06764700 2002.0000


* Using a multi-component time-based deformation model with the :ref:`defmodel` operator.

  For example, to transform coordinates from ITRF96 at epoch 2026.0 to NZGD2000

  ::

        $ echo -41.2924 174.7787 0 2026 | PROJ_NETWORK=ON cs2cs -d 8 ITRF96 NZGD2000

        -41.29240855 174.77870601 0.00000000 2026

  or (since PROJ 9.9)

  ::

        $ echo -41.2924 174.7787 0 | PROJ_NETWORK=ON cs2cs -d 8 ITRF96@2026 NZGD2000

        -41.29240855 174.77870601 0.00000000


  or equivalently using the PROJ pipeline returned by
  ``projinfo ITRF96@2026 NZGD2000 --spatial-test intersects``
  
  ::

        echo -41.2924 174.7787 0 | PROJ_NETWORK=ON cct -d 8 \
          +proj=pipeline \
          +step +proj=axisswap +order=2,1 \
          +step +proj=unitconvert +xy_in=deg +xy_out=rad \
          +step +proj=set +v_4=2026 \
          +step +inv +proj=defmodel +model=nz_linz_nzgd2000-20180701.json \
          +step +proj=set +v_4=2026 \
          +step +proj=unitconvert +xy_in=rad +xy_out=deg \
          +step +proj=axisswap +order=2,1

        -41.29240855    174.77870601    0.00000000     2026.0000


Other types of time-dependent transformations are not yet supported when
PROJ must infer the transformation pipelines:

- time-specific Helmert transformations
- transformations between two dynamic CRS at different epochs
- plate motion models (as available in :source_file:`data/ITRF2008`,
  :source_file:`data/ITRF2014` and :source_file:`data/ITRF2020`).


Through C API
-------------

Since PROJ 9.9, the most convenient way, that will work with all above mentioned
coordinate operations, is to attach an epoch to a dynamic CRS,
forming a :cpp:class:`osgeo::proj::coordinates::CoordinateMetadata` instance,
either by passing a string of the form "<CRS string> @ <epoch>" to :cpp:func:`proj_create`
or :cpp:func:`proj_create_crs_to_crs`. Or when operating on ``PJ*`` instance, to
use :cpp:func:`proj_coordinate_metadata_create` from an existing CRS instance,
and pass it to :cpp:func:`proj_create_crs_to_crs_from_pj` or :cpp:func:`proj_create_operations`

.. code-block:: c

    PJ_CONTEXT *ctxt = proj_context_create();
    PJ *transf = proj_create_crs_to_crs(C, "ITRF2014@2026.0", "GDA2020", nullptr);
    PROJ_COORD coord;
    coord.xyz.y = -33.8623;  // latitude in degree
    coord.xyz.y = 151.2077;  // longitude in degree
    coord.xyz.z = 0;         // ellipsoidal height in meter
    PROJ_COORD coord_in_gda2020 = proj_trans(transf, PJ_FWD, coord);
    proj_destroy(transf);
    proj_context_destroy(ctxt);


When using the :cpp:func:`proj_create_operations` functionality,
:cpp:func:`proj_coordoperation_requires_per_coordinate_input_time` can be used on
the returned operations to check if they have a time dependency.

Note that with PROJ 9.3 or earlier for 15-parameter Helmert or, PROJ 9.8 or
earlier, for multi-component time-based deformation model transformations, you
must set the epoch in the ``PROJ_COORD::xyzt::t`` or ``PROJ_COORD::v[3]`` member
since CoordinateMetadata is not available.
