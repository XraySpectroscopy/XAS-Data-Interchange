c2345678
       program xdi_test1
       character*32 fname

       save
       integer  max_attr, max_pts, max_comments
       integer  mwords , maxcol 
       parameter(mwords = 128, maxcol = 16)
       parameter(max_attr = 256, max_pts = 16384, max_comments=64)

       character*128  words(mwords)
       character*256 comments(max_comments), labels(maxcol)
       character*256 attr_names(max_attr), attr_values(max_attr)

       integer   npts, ipts, i, j, k, istrln, ilen

       double precision energy(max_pts), dat_i0(max_pts)
       double precision dat_it(max_pts), dat_if(max_pts)
       double precision dat_ir(max_pts)

       fname = 'test.xdi'
       call read_xdi(fname,  max_attr, max_pts, max_comments,
     $      attr_names, attr_values, labels, comments,  
     $      npts, energy, dat_i0, dat_it, dat_if, dat_ir)

       return
       end
