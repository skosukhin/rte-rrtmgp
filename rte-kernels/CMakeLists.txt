add_library(rtekernels OBJECT mo_rte_kind.F90)

if(KERNEL_MODE STREQUAL "extern")
  target_sources(
    rtekernels
    PRIVATE # cmake-format: sort
            api/mo_fluxes_broadband_kernels.F90
            api/mo_optical_props_kernels.F90
            api/mo_rte_solver_kernels.F90
            api/mo_rte_util_array.F90
            api/rte_kernels.h
            api/rte_types.h
  )
else()
  target_sources(
    rtekernels
    PRIVATE # cmake-format: sort
            mo_fluxes_broadband_kernels.F90
            mo_rte_util_array.F90
  )
  if(KERNEL_MODE STREQUAL "accel")
    target_sources(
      rtekernels
      PRIVATE # cmake-format: sort
              accel/mo_optical_props_kernels.F90
              accel/mo_rte_solver_kernels.F90
    )
  else()
    target_sources(
      rtekernels
      PRIVATE # cmake-format: sort
              mo_optical_props_kernels.F90
              mo_rte_solver_kernels.F90
    )
  endif()
endif()

include(CheckFortranNeedsCBool)
check_fortran_needs_cbool(RTE_USE_C_BOOL)

target_compile_definitions(
  rtekernels
  PRIVATE $<$<BOOL:${RTE_ENABLE_SP}>:RTE_USE_SP>
          $<$<BOOL:${RTE_USE_C_BOOL}>:RTE_USE_CBOOL>
)

target_include_directories(rtekernels PRIVATE ${CMAKE_Fortran_MODULE_DIRECTORY})
