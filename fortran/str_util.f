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
      subroutine smcase (str, contrl)
c  convert case of string *str*to be the same case
c  as the first letter of string *contrl*
c  if contrl(1:1) is not a letter, *str* will be made lower case.
      character*(*) str, contrl, s1*1, t1*1
      s1 = contrl(1:1)
      t1 = s1
      call lower(t1)
      if (t1.eq.s1)  call lower(str)
      if (t1.ne.s1)  call upper(str)
      return
c end subroutine smcase
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
      subroutine upper (str)
c  changes a-z to upper case.  ascii specific
      character*(*) str
      parameter(iloa= 97, iloz=122, idif= 32)
      do 10 j = 1, len(str)
         i = ichar(str(j:j))
         if ((i.ge.iloa).and.(i.le.iloz)) str(j:j) = char(i-idif)
   10 continue
      return
c end subroutine upper
      end
       subroutine unblnk (string)
c
c remove blanks from a string
       integer        i, ilen, j
       character*(*)  string, str*2048, blank*1
       parameter (blank = ' ')       
       ilen = min(2048, max(1, istrln(string)))
       j   = 0
       str = blank
       do 10 i = 1, ilen
         if (string(i:i).ne.blank) then
            j = j+1
            str(j:j) = string(i:i)
         end if
 10   continue
      string = blank
      string = str(1:j)
      return
c end subroutine unblnk
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

       subroutine strreplace(s,s1,s2)
c replace s1 with s2 in string s
       integer      i, j, i1, i2, istrln, n
       character*(*) s, s1, s2
       i1 = istrln(s1)
       i2 = istrln(s2)

       j = 1
       n = 0
 30    continue
       i = index(s(j:),s1(1:i1))
       n = n+1
       if ((n.le.1024).and.(i .ne. 0)) then
          i = i+j-1
          s = s(1:i-1)//s2(1:i2)//s(i+i1:)
          j = i + i2
          go to 30
       end if
       return
c end subroutine strreplace
       end

      subroutine uncomm(str)
c
c purpose: remove comments from a string
c
c arguments:
c      str  string to modify        [in/out]
c notes:
c   1. '*' is a comment iff it occurs in col 1
c   2. char(10) and char(12) are end-of-line comments
c   3. '!', '#', and '%'  are end-of-line comments that
c       can be protected by matching " ", ' ', ( ), [], or {}
c
c requires:  istrln, triml, echo
c
c copyright 1997  matt newville
       integer i, istrln, ilen, iprot
       character*(*) str, copen*5, cclose*5, eol*3, spec*2, s*1
       character*1 blank, star
       parameter(blank = ' ',star = '*')
       external  istrln
       data copen, cclose, eol  / '[{"''(',  ']}"'')', '!#%' /
c
       spec(1:2) = char(10)//char(12)
       call triml(str)
       ilen = istrln(str)
       if ((ilen.le.0).or.(str(1:1).eq.star)) then
          str = blank
          i   = 1
       else
          iprot = 0
          do 50 i = 1, ilen
             s  = str(i:i)
             if (iprot.le.0) then
                iprot = index(copen,s)
             elseif (iprot.le.5) then
                if (s.eq.cclose(iprot:iprot)) iprot = 0
             else
cc                call echo('** uncomm confusion: iprot out of range')
                return
             end if
c if the string is unprotected, look for end-of-line comment characters
             if (((iprot.eq.0).and.(index(eol,s).ne.0)).or.
     $             index(spec,s).ne.0)  go to 60
 50       continue
          i  = ilen + 1
 60       continue
       end if
       str  = str(1:i-1)
c end subroutine uncomm
       return
       end
      subroutine strclp(str,str1,str2,strout)
c
c  a rather complex way of clipping a string:
c      strout = the part of str that begins with str2.
c  str1 and str2 are subsrtings of str, (str1 coming before str2),
c  and even if they are similar, strout begins with str2
c  for example:
c   1.  str =  "title title my title" with  str1 = str2 = "title"
c       gives strout = "title my title"
c   2.  str =  "id  1  1st path label" with str1 = "1", str2 = "1st"
c       gives strout = "1st path label"
c
      character*(*)  str, str1, str2, strout
      integer  i1, i2, ibeg, iend, istrln, ilen
      external istrln
      ilen   = len(strout)
      i1     = max(1, istrln(str1))
      i2     = max(1, istrln(str2))
      i1e    = index(str,str1(1:i1)) + i1
      ibeg   = index(str(i1e:),str2(1:i2) ) + i1e - 1
      iend   = min(ilen+ibeg, istrln(str) )
      strout = str(ibeg:iend)
      return
c end subroutine strclp
      end
       subroutine rmdels(s,s1,s2)
c
c  remove general enclosing delimeters from a string
       character*(*) s, s1, s2, t*2048
       call triml(s)
       i  = istrln(s)
       t  = s
       if ((s(1:1).eq.s1) .and. (s(i:i).eq.s2)) s = t(2:i-1)
       return
       end
c 
c        subroutine rmpars(str)
c c  remove enclosing parentheses for a string
c        character*(*) str
c        call rmdels(str,'(',')')
c        return
c        end

       subroutine rmquot(str)
c  remove enclosing single or double quotes from a string
       character*(*) str
       call rmdels(str,'''','''')
       call rmdels(str,'"','"')
       return
       end
       subroutine undels(s)
c  remove an enclosing delimiter from a string
       character*(*) s, op*5, cl*5
       integer j
       data op, cl / '[{"''(',  ']}"'')'/
       j = index(op,s(1:1))
       if (j.ne.0) then
          call rmdels(s, op(j:j), cl(j:j) )
       end if
       return
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
      subroutine str2lg(str,flag,ierr)
c  return logical "flag" from character string "str".
c  flag is true unless the first character is
c     '0', 'f' or 'n' (not case-sensitive)
      character*(*) str, test*5
      parameter (test = 'fnFN0')
      logical    flag
      integer    ierr
      ierr  = 0
      flag  = index(test,str(1:1)).eq.0
      return
c end subroutine str2lg
      end
       subroutine str2il(str,miar,niar,iar,ierr)
c  convert a string into an integer _list_, 
c  supporting syntax like '1-2,12,4,6-8' returns
c  iar =   1,2,4,6,7,8,12    niar = 7
c
c  returns ierr = -1 if string clearly non-integer
       character*(*) str, s*1024, sint*64
       integer  miar, niar, iar(miar), ierr, istrln
       integer  i, ibeg
       logical  dash
       external  istrln

       s    = str
       call triml(s)
       if ((s.eq.'all') .or.(s.eq.'all,')) then 
          write(sint, 10)  miar
          call triml(sint)
          s   = '1-'//sint(1:istrln(sint))//','
          call triml(s)
       endif
 10    format(i6)
       ilen = istrln(s)+1
       s    = s(1:ilen-1)//'^'

       do 20 i = 1, miar
          iar(i) = 0
 20    continue 
       niar =  0
       ierr = -1
       ix1  =  0
       dash = .false.
       if (ilen.gt.1) then
          i    = 1
          ibeg = 1
 100      continue 
          i = i + 1
          if ((s(i:i).eq.',') .or. (s(i:i).eq.'^')) then
             sint = s(ibeg:i-1)
             ibeg = i+1
             if (dash) then
                call str2in(sint,ix,ierr)
                do 130 j = ix1, ix
                   niar = niar + 1
                   iar(niar) = j
 130            continue 
             else
                call str2in(sint,ix,ierr)
                niar = niar + 1
                iar(niar) = ix
             end if
             dash = .false.
          elseif (s(i:i).eq.'-') then
             sint = s(ibeg:i-1)
             dash = .true.
             call str2in(sint,ix1,ierr)
             ibeg = i+1
          end if
          if (s(i:i).ne.'^') go to 100
       end if
c now remove the zeroth one!
       niar = niar - 1
c
       return
c end subroutine str2il
       end

      logical function is_comment(line)
c
c  returns true if line is a comment or blank line, false otherwise
c  comment lines start with one of:  '#', '*', ';', '%'
      character*(*) line, l1*1, com*4
      parameter(com = '#*;%')
      integer istrln
      external istrln
      is_comment = .false.
      l1 = line(1:1)
      if ((istrln(line).le.0) .or. (index(com,l1).ge.1)) then
         is_comment = .true.
      endif
      return
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
       logical function isdat(string)
c  tests if string contains numerical data
c    returns true if the first (up to eight) words in string can
c    all be numbers. requires at least two words, and tests only
c    the first eight columns
       integer nwords, mwords, i
       parameter (mwords = 8)
       character*30  string*(*), words(mwords), line*2048
       logical isnum
       external isnum
c
       isdat = .false.
       do 10 i = 1, mwords
          words(i) = 'no'
 10    continue
c
       nwords = mwords
       line   = string
       call triml(line)
       call untab(line)
       call bwords(line, nwords, words)
       if (nwords.ge.1) then
          isdat = .true.
          do 50 i = 1, nwords
             isdat = isdat .and. isnum(words(i))
 50       continue
       end if
       return
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
       subroutine bkeys(str, mkeys, keys, values, nkeys)
c
c purpose:  break a string into {key,value} pairs.
c arguments:
c      str     string to break into pairs           [in]
c      mkeys   dimension of arrays keys and values  [in]
c      keys    character array of keys              [out]
c      values  character array of values            [out]
c      nkeys   number of keys found                 [out]
c
c parsing rules:
c  1. a key is a word terminated by whitespace, an equal sign,
c     a comma, or the final close paren.  keys are converted to
c     lower case before returning.
c
c  2. a value is a more general string, terminated by either
c     an "unprotected" comma or the final "unprotected" close paren.
c     Any part of the string can be "protected" by either matching
c     single quotes, double quotes, parens, braces, or brackets.
c     In fact, *all* of these pairs must be matched for the
c     value to terminate.  the values are left in their original case.
c
c  3. If a key does not have a value (because a comma or the last close
c     paren gets in the way) the value will be set to '%undef%'.
c     note that str2lg will interpret this as "true"!, and that it
c     will never make sense as any other value.
c
c example:  x =13.214, File = B.dat, Verbose, sig = sqrt(A + min(b,c))
c   will return these pairs:
c        key        value
c        x          13.214
c        file       B.dat
c        verbose    %undef%
c        sig        sqrt(A + min(b,c))
c
c  routines needed: istrln, triml, lower, rmdels, echo
c
c  copyright (c) 1998  matt newville
c
       integer   istrln, i, j, ilen, ibeg
       integer   nkeys, mkeys, nk, jprot
       character*(*) str, keys(mkeys), values(mkeys), tmp*2048
       character s, t, u, blank, comma, equal, semicl
       character copen*3, cclose*3, undef*8
       logical   lcomma, seek_key, have_key
       parameter (blank = ' ',comma = ',',equal = '=',semicl = ';')
       parameter (undef = '%undef%')
       external istrln
       data copen, cclose / '[{(',  ']})'/
c
c initialize
       nkeys = 0
       do 10 i = 1, mkeys
          keys(i)   = blank
          values(i) = undef
 10    continue
       have_key = .false.
       seek_key = .true.
       lcomma   = .false.
       ibeg     = 1
       iprot    = 0
       jprot    = 0
c
c check for valid string to parse
       ilen = istrln(str)
cc       print*,'BKEYS:',str(1:ilen),':', ilen
       if (ilen .eq. 0)  return
c
c loop through string
       i = 0
 100   continue 
       i = i + 1
       s  = str(i:i)
c test for opening/closing delimiters
c and march over protected strings
       if ((s.eq.'''').or.(s.eq.'"')) then 
          t = s
cc          print*, ' quote: ', t
 120      continue
          i  = i + 1
          if ((str(i:i).ne.t).and.(i.lt.ilen)) goto 120
       else
          iprot = index(copen,s)
          if ((iprot.ge.1).and.(iprot.le.3)) then
cc             print*, ' iprot = ',iprot , s, i
             jprot= jprot + 1
             t = copen(iprot:iprot)
             u = cclose(iprot:iprot)
 130         continue
             i  = i + 1
             if (str(i:i).eq.t)  jprot = jprot + 1
             if (str(i:i).eq.u)  jprot = jprot - 1
             if ((i.lt.ilen).and.(jprot.ne.0)) goto 130
          end if
       endif
       lcomma = s.eq.comma
c looking for keyword:
c   we've seen the beginning of a keyword, and now we see the end:
c   keyword  ends at "=",","," ", or the final positon
       if (seek_key) then
          if (((s.eq.equal).or.lcomma.or.(i.eq.ilen))) then
             nkeys  = nkeys + 1
             if (nkeys .ge. mkeys) go to 150
             keys(nkeys) = str(ibeg:i-1)
             if ((i.eq.ilen).and.(.not.lcomma).and.(s.ne.equal))
     $            keys(nkeys) = str(ibeg:i)
cc             print*, 'found key : ', nkeys, ' ', keys(nkeys)(1:32)
             ibeg   = min(i + 1, ilen)
             seek_key = .false.
             have_key = .false.
c      a bare word counts as a key with value= undefined (as above)
             if (lcomma .or.(i.eq.ilen) ) then
                seek_key = .true.
                call triml(keys(nkeys))
                ij = istrln(keys(nkeys))
                if  (index(keys(nkeys)(1:ij),blank).ne.0) then
                   tmp = keys(nkeys)(1:ij)
c      c                        call echo(' syntax error: '//tmp)
                   keys(nkeys)  = blank
                end if
             end if
          elseif (.not.have_key) then
             have_key = s.ne.blank
          end if
c      looking for a value:  ends at a comma or the final postion
       else
          if (lcomma.or.(i.eq.ilen)) then
             values(nkeys) = str(ibeg:i-1)
             if ((i.eq.ilen).and.(.not.lcomma))
     $            values(nkeys) = str(ibeg:)
             ibeg   = min( i + 1, ilen)
             seek_key = .true.
          end if
       end if
       if (i.le.ilen) goto 100
 150   continue 
c
c  finally, we may have ended with a one-letter keyword, in which case
c   have_key is true
       if (have_key) then
          nkeys       = nkeys + 1
          keys(nkeys) = str(ibeg:)
          call triml(keys(nkeys))
       end if
c
c now clean up keys and values, eliminate blank and invalid keys

       nk = nkeys
       nkeys = 0
       do 500 i = 1, nk
          if (keys(i).ne.blank .and. keys(i).ne.comma .and.
     $         keys(i).ne.equal .and. keys(i).ne.semicl) then
             nkeys = nkeys + 1
             keys(nkeys) = keys(i)
             call triml( values(i))
             if (values(i)(1:1).eq.equal) then 
                values(i) = values(i)(2:)
                call triml(values(i) )
             end if
             call rmquot(values(i))
             do 470 j = 1, 2
                call rmdels(values(i),copen(j:j),cclose(j:j))
 470         continue
             call triml( values(i))
             values(nkeys) = values(i)
             if (values(nkeys).ne.undef) call lower(keys(nkeys))
             call triml(keys(nkeys))
          end if
          lk = istrln(keys(i))
          lv = istrln(values(i))
cc          print*, i,' |', keys(i)(1:lk),' | ', values(i)(1:lv), '|'
 500   continue
       return
c end subroutine bkeys
       end

