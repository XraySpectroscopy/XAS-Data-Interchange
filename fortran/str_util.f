       subroutine echo(msg)
       character*(*) msg
       integer ilen, istrln
       external istrln
       ilen = istrln(msg)       
       write(*, '(1x, a)') msg(1:ilen)
       return 
       end
       subroutine openfl(iunit, file, status, iexist, ierr)
c  open a file, 
c   if unit <= 0, the first unused unit number greater than 7 will 
c                be assigned.
c   if status = 'old', the existence of the file is checked.
c   if the file does not exist iexist is set to -1
c   if the file does exist, iexist = iunit.
c   if any errors are encountered, ierr is set to -1.
c
c   note: iunit, iexist, and ierr may be overwritten by this routine
       implicit none
       character*(*)  file, status, stat*10
       integer    iunit, iexist, ierr, istrln
       logical    exist, open
c
c make sure there is a unit number, and that it's pointing to
c an unopened logical unit number other than 5 or 6
       ierr   = -3
       iexist =  0
       iunit  = max(1, iunit)
 10    continue 
       inquire (unit=iunit, opened=open)
       if (open) then
          iunit = iunit + 1
          if ((iunit.eq.5).or.(iunit.eq.6)) iunit = 7
          goto 10
       endif
c
c if status = 'old', check that the file name exists
       ierr = -2
       stat =  status                          
       call lower(stat)
       print*, istrln(file), file
       if (stat.eq.'old') then
          iexist = -1
          inquire(file=file, exist=exist)
          if (.not.exist) then
             return
          endif
          iexist = iunit
       end if
c 
c open the file
       ierr = -1
       open(unit=iunit, file=file, status=status, err=100)
       ierr = 0
 100   continue
       return
c end  subroutine openfl
       end

       integer function iread(iunit, line)
c
c reads line from an open file unit (iunit)
c  return values:
c   line length on success
c            -1 on 'end'
c            -2 on 'error'
       implicit none
       character*(*) line
       integer    iunit, istrln, ilen
       external   istrln
       line = ' '
 10    continue 
       read(iunit, '(a)', end = 40, err = 50) line
       call sclean(line)
       call triml(line)
       iread = istrln(line)
       if (iread .eq. 0) goto 10
       return
 40    continue 
       ilen = istrln(line)
       if (ilen.ge.1) then
          call sclean(line)
          call triml(line)
          iread = ilen
       else 
          line = ' '
          iread= -1
       endif
          
       return
 50    continue 
       line = ' '
       iread = -2
       return
       end

       subroutine sclean(str) 
c
c  clean a string so that all: 
c     char(0), and char(10)...char(15) are end-of-line comments,
c        so that all following characters are explicitly blanked.
c     all other characters below char(31) (including tab) are
c        replaced by a single blank
c
c  note that this is mostly useful when getting a string generated
c  by a non-fortran process (say, a C program) and for dealing with
c  dos/unix/max line-ending problems
       character*(*) str, blank*1
       parameter (blank = ' ')
       integer i,j,is
       do 20 i = 1, len(str)
          is = ichar(str(i:i))
          if ((is.eq.0) .or. ((is.ge.10) .and. (is.le.15))) then
             do 10 j= i, len(str)
                str(j:j) = blank
 10          continue
             return
          endif
          if (is.le.31) str(i:i)  = blank
 20    continue 
       return
c end subroutine sclean
       end

       subroutine triml (string)
c removes leading blanks.
       character*(*)  string, blank*1
       parameter (blank = ' ')
c-- all blank and null strings are special cases.
       jlen = istrln(string)
       if (jlen .eq. 0)  return
c-- find first non-blank char
       do 10  i = 1, jlen
          if (string (i:i) .ne. blank)  goto 20
 10    continue
 20    continue
c-- if i is greater than jlen, no non-blanks were found.
       if (i .gt. jlen)  return
c-- remove the leading blanks.
       string = string (i:)
       return
c end subroutine triml
       end
       function istrln(str)
c returns index of last non-blank character,
c         0 if string is null or blank.
       character*(*) str, blank*1
       parameter (blank = ' ')
       ilen   = len(str)
       istrln = 0
       if ((str(1:1).eq.char(0)) .or. (str.eq.blank)) return
       do 10  l = ilen, 1, -1
          if (str(l:l) .ne. blank)  then
             istrln = l
             return
          endif
 10    continue
       return
c end function istrln
       end

      subroutine lower (str)
c  changes a-z to lower case.  ascii specific
      character*(*) str
      parameter(iupa= 65, iupz= 90, idif= 32)
      do 10 j = 1, len(str)
         i = ichar(str(j:j))
         if ((i.ge.iupa).and.(i.le.iupz)) str(j:j) = char(i+idif)
   10 continue
      return
c end subroutine lower
      end
       subroutine strsplit(sinp, nwords, words, delim)
c
c  breaks string into words using a single delimeter
c  nwords:  max number of words (input), number of words (output)
c  words:   pieces of the string
c  delim:   delimeter to split string on.  Can be multi-character,
c           but cannot be 'multi-blanks' -- these are folded into
c           a delimiter of a single blank (the default).
       implicit none
       integer ldel, i, j, nwords, mwords, istrln
       character*(*) sinp, words(nwords), delim
       external istrln

       ldel = istrln(delim)
       if ((delim.eq.' ').or.(ldel.lt.1)) then
          ldel = 1
          delim = ' '
       endif
       mwords = nwords
       nwords = 0
       call triml(sinp)
       if (istrln(sinp) .eq. 0) return

       j = 1
 30    continue
       i = index(sinp(j:),delim(1:ldel))
       if ((i.gt.0).and.(nwords.lt.mwords-1)) then
c this ignores blank words (multiple delimeters)
          if (i.gt.1) then   
             nwords = nwords + 1
             words(nwords) = sinp(j:j+i-2)
          endif
          j = j+i+ldel-1 
          go to 30
       end if
       nwords = nwords + 1
       words(nwords) = sinp(j:)

       return
c end subroutine strsplit
       end

      subroutine str2dp(str,dpval,ierr)
c  return dp number "dpval" from character string "str"
c  if str cannot be a number, ierr < 0 is returned.
      character*(*) str, fmt*15 
      double precision dpval
      integer  ierr 
      logical  isnum
      external isnum
      ierr = -999
      if (isnum(str)) then
         ierr = 0
         write(fmt, 10) min(999,max(2,len(str)))
 10      format('(bn,f',i3,'.0)')
         read(str, fmt, err = 20, iostat=ierr) dpval
      end if    
      if (ierr.gt.0) ierr = -ierr
      return
 20   continue
      ierr = -998
      return
c end subroutine str2dp
      end

      subroutine str2re(str,val,ierr)
c  return real from character string "str"
      character*(*) str 
      double precision dpval
      real     val
      integer  ierr
      call str2dp(str,dpval,ierr)
      if (ierr.eq.0) val = real(dpval)
      return
c end subroutine str2re
      end

      subroutine str2in(str,intg,ierr)
c  return integer from character string "str"
c  returns ierr = 1 if value was clearly non-integer
      character*(*) str 
      double precision val, tenth
      parameter (tenth = 1.d-1)
      integer  ierr, intg
      call str2dp(str,val,ierr)
      if (ierr.eq.0) then
         intg = int(val)
         if ((abs(intg - val) .gt. tenth))  ierr = 1
       end if
      return
c end subroutine str2in
      end

       logical function isnum (string)
c  tests whether a string can be a number. not foolproof!
c  to return true, string must contain:
c    - only characters in  'deDE.+-, 1234567890' (case is checked)
c    - no more than one 'd' or 'e' 
c    - no more than one '.'
c    - if '+' or '-' is seen after a digit, 'deDE' must be seen.
c  matt newville
       character*(*)  string,  number*20
c note:  layout and case of *number* is important: do not change!
       parameter (number = 'deDE.,+- 1234567890')
       integer   iexp, idec, i, j, istrln, isign
       integer   jexp
       logical   ldig, l_op
       external  istrln
c       str   = string
c       call triml(str)
       iexp  = 0
       jexp  = 0
       idec  = 0
       isign = 0
       ldig  = .false.
       l_op  = .false.
       isnum = .false. 
       do 100  i = 1, max(1, istrln(string))
          j = index(number,string(i:i))
cc          print*, 'X  ' , i, j, ' : ' , str(i:i)
          if (j.le.0)               go to 200
          if (j.ge.10)              ldig = .true.
          if((j.ge.1).and.(j.le.4)) then 
             iexp = iexp + 1
             jexp = i
          endif
          if (j.eq.5)               idec = idec + 1
          if ((j.eq.7).or.(j.eq.8)) then
             isign= isign +1
             if ((i .gt. 1) .and. (i .ne. (jexp+1))) then
                l_op = .true.
             endif
          endif
 100   continue
c  every character in "string" is also in "number".  so, if there are 
c  not more than one exponential and decimal markers, it's a number
       if ((iexp.le.1).and.(idec .le.1)) isnum = .true.
       if ((iexp.eq.0).and.(isign.gt.1)) isnum = .false.
       if (jexp.eq.1)  isnum = .false.
       isnum = isnum .and. (.not.l_op)
cc       print*, 'ISNUM: ', string(1:istrln(string))
cc       print*, '       ', isnum, l_op, iexp, idec, isign
 200   continue
       return
c  end logical function isnum
       end
       subroutine untab(string)
c replace tabs with blanks :    tab is ascii dependent
       integer      itab , i
       parameter    (itab = 9)
       character*(*) string, blank
       parameter (blank = ' ')        
 10    continue
       i = index(string, char(itab))
       if (i .ne. 0) then
          string(i:i) = blank
          go to 10
       end if
       return
c end subroutine untab
       end

       subroutine bwords (str, nwords, words)
c
c     breaks string into words.  words are separated by a
c     whitespace (blank or tab), comma, or equal sign,
c     plus zero or more whitespaces.
c
c     args        i/o      description
c     ----        ---      -----------
c     s            i       char*(*)  string to be broken up
c     nwords      i/o      input:  maximum number of words to get
c                          output: number of words found
c     words(nwords) o      char*(*) words(nwords)
c                          contains words found.  words(j), where j is
c                          greater then nwords found, are undefined on
c                          output.
c
c      written by:  steven zabinsky, september 1984
c      altered by:  matt newville
c**************************  deo soli gloria  **************************
c-- no floating point numbers in this routine.
       character*(*) str, words(nwords)
       character blank, comma, equal, s
       parameter (blank = ' ', comma = ',', equal = '=')
       external istrln
c-- betw    .true. if between words
c   comfnd  .true. if between words and a comma or equal has
c                                         already been found
      logical betw, comfnd
c-- define tab character (ascii dependent)
       mwords = nwords
       nwords = 0
       call untab (str)
       call triml (str)
       ilen = istrln (str)
c-- all blank string is special case
       if (ilen .eq. 0) return
c-- ibeg is beginning character of a word
       ibeg = 1
       betw   = .true.
       comfnd = .true.
       do 10  i = 1, ilen
          s = str(i:i)
          if (s .eq. blank)  then
             if (.not. betw)  then
                nwords = nwords + 1
                words (nwords) = str (ibeg : i-1)
                betw = .true.
                comfnd = .false.
             endif
          elseif ((s.eq.comma).or.(s.eq.equal))  then
             if (.not. betw)  then
                nwords = nwords + 1
                words (nwords) = str(ibeg : i-1)
                betw = .true.
             elseif (comfnd)  then
                nwords = nwords + 1
                words (nwords) = blank
             endif
             comfnd = .true.
          else
             if (betw)  then
                betw = .false.
                ibeg = i
             endif
          endif
          if (nwords .ge. mwords)  return
 10    continue
c
       if (.not. betw  .and.  nwords .lt. mwords)  then
          nwords = nwords + 1
          words (nwords) = str (ibeg :ilen)
       endif
       return
c end subroutine bwords
       end
