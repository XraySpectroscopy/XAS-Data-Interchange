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
       double precision dat_ir(max_pts)
       
       logical isComment
       integer    lun, nwords,  iex, ier, jline
       character*(*)  stat*10,  comchr*1, cchars*2
       character*128  tmpline, state*16, tmpstr*256
       character*2048 line, labstr, msg
       external istrln, iread
       npts = max_pts

       cchars = ';#'

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
cc           print*, lun, stat, iex, ier
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
       if (ilen .lt. 0) goto 2900
cc       print*,  ilen, line(1:50)
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
ccc       print*, nwords, words(1), words(2), words(3)
       print*, words(1)(1:20), isComment, state, tmpline(1:3), 
     $   tmpline(1:3).eq.'///'
       
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
          print*, ' Field Line: ', words(1), words(2)
          tmpstr = words(1)(:istrln(words(1))-1)
          iattr = iattr + 1
          attr_names(iattr)  = tmpstr(1:istrln(tmpstr))
          attr_values(iattr) = words(2)(1:istrln(words(2)))
c$$$ 121      format ('Application_',i1.1)
c$$$          if (nwords .ge. 1) then
c$$$             do i = 1, nwords-1 
c$$$                iattr = iattr+1
c$$$                write(tmpstr, 121) i
c$$$                attr_names(iattr) = tmpstr(1:istrln(tmpstr))

c$$$             enddo
c$$$          endif

       endif


c$$$       if ((line(3:7).eq.'-----').and.(type.eq.'label')) then

       if ((ilen.ge.0).or.(line.eq.' ')) goto 100
c parsing complete
 200   continue 

 2900  continue 
       if (lun.gt.0) close(lun)

      return
c  end subroutine read_xdi
      end

c$$$c
c$$$c read file, ignoring title lines at top of file.
c$$$c  -  when we read the first row of numerical data, count the 
c$$$c     number of columns and assign names and positions to vectors
c$$$       nwords = mwords
c$$$       ntitle = 0
c$$$       cchars = ';#%'//comchr
c$$$       istitl = .true.
c$$$       iscomm  = .true.
c$$$       iscomm2 = .true.
c$$$       
c$$$c
c$$$c
c$$$c title lines
c$$$ 100   continue
c$$$       ilen = iread(lun,  line)
c$$$       if (ilen .lt. 0) goto 2900
c$$$       jxline = jxline + 1
c$$$       tmpnam = line(1:64)
c$$$       nwords = 1
c$$$       call triml(tmpnam)
c$$$       call lower(tmpnam)
c$$$       call bwords(tmpnam, nwords, words)
c$$$
c$$$       iscomm2 = (line(1:1).ne.' ').and.(index(cchars,line(1:1)).ne.0)
c$$$       call str2dp(words(1), xx, ier)
c$$$       iscomm = ier.ne.0
c$$$cc       print*, words(1), iscomm, iscomm2
c$$$c      c       .not.isnum(words(1))
c$$$
c$$$c       if (iscomm.neqv.iscomm2) then
c$$$c          call warn(3, ' *** read_data: uncertain about comment')
c$$$c          write(messg, '(3x,a)') line(1:40)
c$$$c          call warn(3,messg)
c$$$c          print*,  iscomm, words(1)
c$$$c       endif
c$$$
c$$$       if ((ilen.le.0).or.(line.eq.' ')
c$$$     $      .or.(jxline.le.in_titles)) goto 100
c$$$c check for label line
c$$$       if  (line(3:7).eq.'-----')  istitl = .false.
c$$$       if ((line(3:7).eq.'-----').and.(type.eq.'label')) then
c$$$          ilen = iread(lun, line)
c$$$          if (ilen .lt. 0) goto 700
c$$$          jxline = jxline + 1
c$$$          if (iscomm) line = line(2:)
c$$$          call triml(line)
c$$$          call lower(line)
c$$$          nwords  = mwords
c$$$          call bwords(line, nwords, words)
c$$$          llen  = 1
c$$$          do 130 i = 1, nwords
c$$$             j      = index(words(i),'.')
c$$$             suffix = words(i)(j+1:)
c$$$             lslen  = istrln(suffix)
c$$$             labstr = labstr(1:llen)//blank//suffix(1:lslen)
c$$$             llen   = istrln(labstr)
c$$$ 130      continue 
c$$$c nlab:  number of labels read in
c$$$          nlabs = nwords
c$$$          goto 200
c$$$       end if
c$$$c
c$$$c read titles into temporarily-named arrays (they'll be renamed 
c$$$c according to group below)
c$$$ 145   format ('$',a,'_title_',i2.2)
c$$$       if (iscomm) then
c$$$          if (save_titles.and.istitl.and.(ntitle.lt.nt_max)) then
c$$$             line   = line(2:)
c$$$             ntitle = ntitle + 1
c$$$             write(tmpstr, 145) pre(1:ilpre), ntitle
c$$$             call settxt(tmpstr,   line)
c$$$          endif
c$$$          goto 100
c$$$       elseif (isdat(line)) then
c$$$          nwords = mwords
c$$$          call bwords(line, nwords, words)
c$$$          goto 210
c$$$       else
c$$$          goto 100
c$$$       end if 
c$$$c
c$$$c
c$$$c  read numerical data
c$$$ 200   continue
c$$$       ilen = iread(lun, line)
c$$$       if (ilen .lt. 0) goto 700
c$$$       jxline = jxline + 1
c$$$       iscomm = (line(1:1).ne.' ').and.(index(cchars,line(1:1)).ne.0)
c$$$       if (iscomm.or.(ilen.le.0).or.(line.eq.' ')) goto 200
c$$$ 210   continue
c$$$       nwords = mwords
c$$$       call bwords(line, nwords, words)
c$$$c  here we have the first real row of numerical data. 
c$$$c  save number of arrays to use
c$$$       npts = npts + 1
c$$$       if (npts.eq.1) then
c$$$          nwords1 = nwords
c$$$          if (narrs.eq.0) narrs = nwords
c$$$          if ((type.ne.'label').and.(type.ne.'user')) then
c$$$             do 250 in = 1, narrs
c$$$                call file_type_names(type,in,suffix)
c$$$                lslen  = istrln(suffix)
c$$$                labstr = labstr(1:llen)//blank//suffix(1:lslen)
c$$$                llen   = istrln(labstr)                
c$$$ 250         continue
c$$$          endif
c$$$       endif
c$$$       if (nwords.ne.nwords1) then
c$$$          write(messg, '(3x,a,i5)') ' *** read_data: inconsistent '//
c$$$     $         'number of columns at line  ',  jxline
c$$$          call warn(1,messg)
c$$$       endif
c$$$cc       print*,  jxline, nwords, '   : ', line(1:30)
c$$$       do 580 i = 1, nwords
c$$$          ndata = ndata + 1
c$$$          if (ndata .lt. maxbuf) then
c$$$             call str2dp(words(i), buffer(ndata), ier)
c$$$             if (ier.ne.0) then
c$$$                if (lun.gt.0) close (lun)
c$$$                call echo(' *** read_data: non numeric data in file!')
c$$$                write(messg, '(3x,a,i5)') ' *** read_data: at line  ',
c$$$     $               jxline
c$$$                call echo(messg)
c$$$                write(messg, '(3x,a)') line(1:ilen)
c$$$                call warn(3,messg)
c$$$                return
c$$$             endif
c$$$          end if
c$$$ 580   continue 
c$$$       if (j.ge.maxbuf) then
c$$$          write(messg, '(3x,a)')
c$$$     $         ' *** read_data: file larger than buffer size'
c$$$          call warn(3,messg)
c$$$          return
c$$$       else
c$$$          goto 200
c$$$       endif
c$$$ 700   continue 
c$$$c
c$$$c  done reading numerical data
c$$$       if (narrs.le.0) goto 2900
c$$$       npts = ndata/narrs
c$$$       if (npts .gt. maxsize_array) then 
c$$$          npts = maxsize_array
c$$$          write(messg, '(3x,2a,i6,a)') 'warning: file has more ',
c$$$     $         'data points than maximum array size (',
c$$$     $         maxsize_array,')'
c$$$          call echo(messg)
c$$$          write(messg, '(12x,a)') 'arrays will be truncated.'//
c$$$     $         ' some data will be lost.'
c$$$          call warn(3,messg)
c$$$       endif
c$$$c
c$$$c now we're done reading the data.
c$$$c sort data by a specified column
c$$$       do 1010 i = 1, npts
c$$$          sindex(i) = i
c$$$ 1010  continue 
c$$$       if (do_sort) then
c$$$cc          print*, ' do sort ', isort
c$$$          if ((isort.le.0).or.(isort.gt.narrs)) isort = 1
c$$$          do 1020 i = 1, npts
c$$$             tmparr(i) = buffer(isort + (i-1) * narrs)
c$$$ 1020     continue 
c$$$          if (npts .ge. 2) then
c$$$             call sort2(npts, tmparr,sindex)
c$$$          endif
c$$$       endif
c$$$c
c$$$c put data into arrays and construct output label line
c$$$       nlabs = mwords
c$$$       del   = '.'
c$$$       if (npts .eq. 1) del = '_'
c$$$       do 1400 i = 1, mwords
c$$$          words(i) = ' '
c$$$ 1400  continue 
c$$$       call bwords(labstr, nlabs, words)
c$$$       llen  = 1
c$$$       label = ' '
c$$$       do 1600 i = 1, narrs
c$$$          suffix = words(i)
c$$$          if (.not.(isvnam(suffix, 1) ))  then
c$$$             call fixnam(suffix,2)
c$$$             if (suffix .eq. undef) suffix = ' '
c$$$          end if
c$$$c avoid repeated arrays: since we're sure that the indarrs are different, 
c$$$c       and renaming according to them (without using iff_rename), we 
c$$$c       have to be on the look-out for this case.
c$$$          do 1530 j = 1, i-1
c$$$             if (suffix.eq.words(j)) suffix = ' '
c$$$ 1530     continue 
c$$$          if (suffix.eq. ' ') write(suffix,'(i3)') i
c$$$          call triml(suffix)
c$$$          tmpnam = pre(1:ilpre)//del//suffix
c$$$          lslen = istrln(suffix)
c$$$          newlen= llen + lslen + 1
c$$$          if (newlen.ge. mlabel_len)  then
c$$$             nlabel_out = nlabel_out + 1
c$$$             if (nlabel_out.ge.10) then 
c$$$                write(labnam,2002) 'column_label', nlabel_out
c$$$             else
c$$$                write(labnam,2001) 'column_label', nlabel_out
c$$$             endif
c$$$             call settxt(labnam,label)
c$$$             label = ''
c$$$             llen  = 1
c$$$          endif 
c$$$          label = label(1:llen)//blank//suffix(1:lslen)
c$$$          llen  = istrln(label)
c$$$          do 1550 j = 1, npts
c$$$             tmparr(j) = buffer(i +  (int(sindex(j))-1) * narrs)
c$$$ 1550     continue 
c$$$          if (npts .gt. 1) then
c$$$             call set_array(suffix, pre, tmparr, npts, 1)
c$$$          else
c$$$             call setsca(tmpnam,tmparr(1))
c$$$          endif
c$$$
c$$$ 1600  continue 
c$$$c
c$$$ 2001  format(a12,i1.1)
c$$$ 2002  format(a12,i2.2)
c$$$c
c$$$       if (llen .ge.1) then
c$$$          nlabel_out = nlabel_out + 1
c$$$          if (nlabel_out.ge.10) then 
c$$$             write(labnam,2002) 'column_label', nlabel_out
c$$$          else
c$$$             write(labnam,2001) 'column_label', nlabel_out
c$$$          endif
c$$$          call settxt(labnam,label)
c$$$          label = ''
c$$$       endif
c$$$          
c$$$c finally set all the program variables
c$$$       call setsca('&n_arrays_read',  narrs*1.d0)
c$$$       call settxt('group',    pre)
c$$$       call settxt('filename', file)
c$$$       call settxt('commentchar', comchr)
c$$$       tmparr(1) = nlabel_out
c$$$       call setsca('ncolumn_label', tmparr(1))
c$$$       call gettxt('column_label1', label)
c$$$       call settxt('column_label', label)
c$$$c close unit if still opened
c$$$ 2900  continue 
c$$$       if (lun.gt.0) close(lun)
c$$$       call iff_sync
c$$$       return
c$$$c  end subroutine iff_rddata
c$$$       end
