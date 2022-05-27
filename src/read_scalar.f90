submodule (nc4fortran:read) reader_scalar

implicit none (type, external)

contains


module procedure nc_read_scalar
integer :: varid, ier, i, dimids(1)
integer :: dims
character(:), allocatable :: buf

if(.not.self%is_open) error stop 'ERROR:nc4fortran:reader file handle not open'

ier = nf90_inq_varid(self%ncid, dname, varid)
if (check_error(ier, dname)) error stop 'ERROR:nc4fortran:read inquire_id ' // dname // ' in ' // self%filename

select type (value)
type is (character(*))
  !! NetCDF4 requires knowing the exact character length as if it were an array without fill values
  !! HDF5 is not this strict; having a longer string variable than disk variable is OK in HDF5, but not NetCDF4
  ier = nf90_inquire_variable(self%ncid, varid, dimids = dimids)
  if(check_error(ier, dname)) error stop 'ERROR:nc4fortran:read_scalar: could not get dimension IDs for: ' // dname

  ier = nf90_inquire_dimension(self%ncid, dimid=dimids(1), len=dims)
  if(ier/=NF90_NOERR) error stop 'ERROR:nc4fortran:read_scalar: querying dimension size'

  allocate(character(dims) :: buf)
  ier = nf90_get_var(self%ncid, varid, buf)
  i = index(buf, c_null_char) - 1
  if(i == -1) i = len_trim(buf)
  value = buf(:i)
type is (real(real64))
  ier = nf90_get_var(self%ncid, varid, value)
type is (real(real32))
  ier = nf90_get_var(self%ncid, varid, value)
type is (integer(int64))
  ier = nf90_get_var(self%ncid, varid, value)
type is (integer(int32))
  ier = nf90_get_var(self%ncid, varid, value)
class default
  ier = NF90_EBADTYPE
end select
if (check_error(ier, dname)) error stop 'ERROR:nc4fortran:read_scalar: failed ' // dname // ' in ' // self%filename

end procedure nc_read_scalar

end submodule reader_scalar