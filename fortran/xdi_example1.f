       program xdi_test1

       implicit none 
       save

       character*32 fname

       integer  max_attr, max_pts, max_comments, i, istrln
       integer  maxcol,  npts
       parameter(maxcol = 16)
       parameter(max_attr = 256, max_pts = 16384, max_comments=64)

       character*256 comments(max_comments), labels(maxcol), version
       character*256 attr_names(max_attr), attr_values(max_attr)

       double precision energy(max_pts), dat_i0(max_pts)
       double precision dat_it(max_pts), dat_if(max_pts)
       double precision dat_ir(max_pts)

       fname = '../data/test_01.xdi'

       call read_xdi(fname,  max_attr, max_pts, max_comments,
     $      attr_names, attr_values, version, labels, comments,  
     $      npts, energy, dat_i0, dat_it, dat_if, dat_ir)

       print*, ' ------------'
       print*, '== Version: ', version
       print*, '== Labels'
       do i = 1, maxcol
          if (istrln(labels(i)) .ge. 1) then
             print*, '     ', i, ' = ', labels(i)(1:istrln(labels(i)))
          endif
       enddo
       print*, '== Comments'
       do i = 1, max_comments
          if (istrln(comments(i)) .ge. 1) then
             print*, '     ', i, ' = ', 
     $         comments(i)(1:istrln(comments(i)))
          endif
       enddo
       print*, '== Attributes'
       do i = 1, max_attr
          if (istrln(attr_names(i)) .ge. 1) then
             print*,  attr_names(i)(1:istrln(attr_names(i))), ' = ',
     $            attr_values(i)(1:istrln(attr_values(i)))
          endif
       enddo
       print*, '== Data ', npts
       do i = 1, npts
          print*, energy(i), dat_i0(i), dat_it(i), dat_if(i), dat_ir(i)
       enddo
       return
       end
