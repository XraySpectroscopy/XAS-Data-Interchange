       subroutine read_xdi(fname,  max_attr, max_pts, max_comments,
     $     attr_names, attr_values, version, labels, comments,  
     $     npts, energy, dat_i0, dat_it, dat_if, dat_ir)

c 
c Read/Write XAS Data Interchange Format for Fortran
c
c    To the extent possible, the authors have waived all rights  
c    granted by copyright law and related laws for the code and 
c    documentation that make up the Fortran Interface to the 
c    XAS Data Interchange Format.  While information about 
c    Authorship may be retained in some files for historical 
c    reasons, this work is hereby placed in the Public Domain.  
c    This work is published from: United States.
c
c Matt Newville <newville@cars.uchicago.edu>
c Last Update:  2011-March-08
c
       implicit none
       save
       integer  max_attr, max_pts, max_comments, mwords, maxcol
       parameter(mwords = 128, maxcol = 16)

       character*128  words(mwords)
       character*(*)  comments(max_comments), labels(maxcol)
       character*(*)  attr_names(max_attr), attr_values(max_attr)
       character*(*)  fname, version
       integer   npts, istrln, ilen, iread
       integer i, icomm, iattr
       double precision energy(max_pts), dat_i0(max_pts)
       double precision dat_it(max_pts), dat_if(max_pts)
       double precision dat_ir(max_pts), dpval
       
       logical isComment
       integer    lun, nwords,  iex, ier, jline, ipt
       integer  icole, icol0, icolt, icolf, icolr
       character*(*)  stat*10,  cchars*2
       character*128  tmpline, state*16, tmpstr*256
       character*2048 line, labstr, msg
       external istrln, iread


       npts = max_pts
       cchars = ';#'
c column indices for i0, energy, trans, fluor, refer       
       icol0 = -1
       icole = -1
       icolt = -1
       icolf = -1
       icolr = -1
       ipt   = 0
c now that the needed program variables are known, the strategy is:
c   1. open file, with error checking
c   2. determine # of arrays to read
c   3. assign names and positions for arrays to be read
c   4. read arrays from file
c   5. assign number of points for each array
c
c  open file
       iex = 1
       ier = 0
       lun = -1
       stat = 'old'
       ilen = istrln(fname)
       call openfl(lun, fname(1:ilen), stat, iex, ier)
       if ((ier.lt.0).or.(iex.lt.0)) then
          ilen = istrln(fname)
          msg =   '**  '//fname
          call echo('** read_xdi: error opening file')
          call echo(msg)
          if (lun.gt.0) close(lun)
          return
       end if

c while loop for reading data from open file
       jline = 0
       icomm = 0
       iattr = 0
       isComment = .false.
       state = 'VERSION'
100    continue
       ilen = iread(lun,  line)
       if (ilen .lt. 0) goto 900
       jline = jline + 1
       call triml(line)
       if ((ilen.le.1).or.(line.eq.' ')) goto 100

       isComment = (line(1:1).ne.' ').and.(index(cchars,line(1:1)).ne.0)
       if (isComment) then
          line = line(2:)
       endif

       tmpline = line(1:128)
       call lower(tmpline)
       nwords = 3
       call bwords(tmpline, nwords, words)
       
       if  (tmpline(1:3).eq.'---')  then
          state = 'LABELS'
       else if (tmpline(1:3).eq.'///') then
          state = 'COMMENTS'
       else if (state.eq.'VERSION') then
          call triml(line)
          if (line(1:4).ne.'XDI/') then 
             ilen = istrln(fname)
             msg =   '**  '//fname
             call echo('** read_xdi: invalid XDI File')
             call echo(msg)
             return
          endif
          nwords = 3
          call bwords(line(5:), nwords, words)
          version = words(1)(1:istrln(words(1)))
 121      format ('Application_',i1.1)
          if (nwords .ge. 1) then
             do i = 1, nwords-1 
                iattr = iattr+1
                write(tmpstr, 121) i
                attr_names(iattr) = tmpstr(1:istrln(tmpstr))
                attr_values(iattr) = words(i+1)(1:istrln(words(i+1)))
             enddo
          endif
          state = 'FIELDS'
       else if (state.eq.'LABELS') then
          labstr = line(1:istrln(line))
          nwords = maxcol
          call bwords(labstr, nwords, words)
          do i = 1, nwords
             labels(i) = words(i)(1:istrln(words(i)))
          end do
          state = 'DATA'
       else if (state.eq.'COMMENTS') then
          icomm = icomm + 1
          if (icomm.le.max_comments) then
             comments(icomm) = line(1:istrln(line))
          endif
       else if (state.eq.'FIELDS') then
          nwords = 2
          call  strsplit(line, nwords, words, ':')
          tmpstr = words(1)(:istrln(words(1)))
          iattr = iattr + 1
          attr_names(iattr)  = tmpstr(1:istrln(tmpstr))
          attr_values(iattr) = words(2)(1:istrln(words(2)))
          call lower(tmpstr)
          if (tmpstr(1:7).eq.'column_') then
             tmpstr = tmpstr(8:20)
             if (tmpstr(1:2) .eq. 'i0') then
                call str2in(attr_values(iattr), icol0, ier)
             else if (tmpstr(1:6) .eq. 'itrans') then
                call str2in(attr_values(iattr), icolt, ier)
             else if (tmpstr(1:6) .eq. 'energy') then
                call str2in(attr_values(iattr), icole, ier)
             else if (tmpstr(1:6) .eq. 'ifluor') then
                call str2in(attr_values(iattr), icolf, ier)
             else if (tmpstr(1:6) .eq. 'irefer') then
                call str2in(attr_values(iattr), icolr, ier)
             endif
          endif
       else if (state.eq.'DATA') then
          ipt = ipt + 1
          nwords = mwords
          call  bwords(line, nwords, words)
          do i = 1, nwords 
             call str2dp(words(i), dpval, ier)
             if (i.eq.icole) then 
                energy(ipt) = dpval
             else if (i.eq.icol0) then
                dat_i0(ipt) = dpval
             else if (i.eq.icolt) then
                dat_it(ipt) = dpval
             else if (i.eq.icolf) then
                dat_if(ipt) = dpval
             else if (i.eq.icolr) then
                dat_ir(ipt) = dpval
             endif
          enddo
          npts = ipt

       endif

       if ((ilen.ge.0).or.(line.eq.' ')) goto 100

c parsing complete
 900  continue 
       if (lun.gt.0) close(lun)

      return
c  end subroutine read_xdi
      end

