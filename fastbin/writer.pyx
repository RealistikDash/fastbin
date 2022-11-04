from cpython.bytes cimport PyBytes_FromStringAndSize
from libc.stdint cimport *
from libc.stdlib cimport malloc
from libc.stdlib cimport free
from libc.string cimport memcpy

DEF START_ALLOC = 32

cdef class BinaryWriter:
    cdef char* buffer_start
    cdef char* buffer_end
    cdef char* buffer_ptr

    def __init__(self, bytes buffer = None):
        if buffer is None:
            self.create_initial_buffer()
        else:
            self.create_from_bytes(buffer)

    def __dealloc__(self):
        free(self.buffer_start)

    cdef create_initial_buffer(self):
        cdef char* buffer = <char*>malloc(START_ALLOC)
        self.register_buffer(buffer, START_ALLOC)

    cdef create_from_bytes(self, bytes buffer_py):
        cdef size_t buf_size = len(buffer_py)
        cdef char* buffer = <char*>buffer_py
        self.register_buffer(buffer, buf_size)

    cdef register_buffer(self, char* start, size_t size):
        self.buffer_start = start
        self.buffer_ptr = start
        self.buffer_end = start + size

    # Creates a new buffer for the writer, moving data from the prev one
    cdef create_new_buffer(self, size_t size):
        cdef char* new_buf = <char*>malloc(size)

        memcpy(new_buf, self.buffer_start, self.buffer_end - self.buffer_start)
        free(self.buffer_start)
        self.register_buffer(new_buf, size)

    cdef ensure_capacity(self, size_t extra):
        # Ensures that the data being added on is within the capacity of the buffer.
        cdef space_used = self.buffer_ptr - self.buffer_start
        cdef capacity = self.buffer_end - self.buffer_start
        if space_used >= capacity:
            # Figure out how much space would be left with the new capacity
            print(capacity, space_used, extra)
            while capacity - space_used < extra:
                capacity *= 2

            self.create_new_buffer(capacity)

    # Safe Python API.
    cpdef bytes into_bytes(self):
        return PyBytes_FromStringAndSize(self.buffer_start, self.buffer_ptr - self.buffer_start)

    cpdef write_u8(self, uint8_t value):
        self.ensure_capacity(sizeof(value))
        memcpy(self.buffer_ptr, &value, sizeof(value)) # TODO: dont use memcpy
        self.buffer_ptr += sizeof(value)

    cpdef write_u16(self, uint16_t value):
        self.ensure_capacity(sizeof(value))
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef write_u32(self, uint32_t value):
        self.ensure_capacity(sizeof(value))
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef write_u64(self, uint64_t value):
        self.ensure_capacity(sizeof(value))
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef write_i8(self, int8_t value):
        self.ensure_capacity(sizeof(value))
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef write_i16(self, int16_t value):
        self.ensure_capacity(sizeof(value))
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef write_i32(self, int32_t value):
        self.ensure_capacity(sizeof(value))
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef write_i64(self, int64_t value):
        self.ensure_capacity(sizeof(value))
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef write_f32(self, float value):
        self.ensure_capacity(sizeof(value))
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    # Unsafe python api
    cpdef unsafe_remaining_capacity(self):
        return self.buffer_end - self.buffer_ptr
    
    cpdef unsafe_allocate(self, size_t size):
        self.create_new_buffer(size)

    cpdef unsafe_write_u8(self, uint8_t value):
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef unsafe_write_u16(self, uint16_t value):
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef unsafe_write_u32(self, uint32_t value):
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef unsafe_write_u64(self, uint64_t value):
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef unsafe_write_i8(self, int8_t value):
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef unsafe_write_i16(self, int16_t value):
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef unsafe_write_i32(self, int32_t value):
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef unsafe_write_i64(self, int64_t value):
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)

    cpdef unsafe_write_f32(self, float value):
        memcpy(self.buffer_ptr, &value, sizeof(value))
        self.buffer_ptr += sizeof(value)
