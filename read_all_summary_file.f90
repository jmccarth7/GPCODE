subroutine read_all_summary_file( i_GP_generation )

! program written by: Dr. John R. Moisan [NASA/GSFC] 31 January, 2013

!xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
! if a restart is requested, 
! read a summary file from a previous run and set the starting trees
! to the values in the file 
!xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   use kinds_mod

   use mpi
   use mpi_module

   use GP_Parameters_module
   use GA_Parameters_module
   use GP_Variables_module
   use GA_Variables_module
   use GP_Data_module
   use GP_variables_module

   implicit none

   integer(kind=i4b) :: i_code_eq
   integer(kind=i4b) :: i
   integer(kind=i4b) :: istat

   integer(kind=i4b),intent(in)  :: i_GP_Generation
   integer(kind=i4b)             :: i_GP_Gen
   integer(kind=i4b)             :: i_GP_indiv

   integer(kind=i4b) :: i_Tree
   integer(kind=i4b) :: i_Node

   logical :: Lprint

   character(2) :: arrow1
   character(2) :: arrow2
   character(200) :: Aline 

!----------------------------------------------------------------------------------------


!---------------------------------------------------
! assume this subroutine is called by all processes. W.J noted
!---------------------------------------------------

   GP_Population_Initial_Conditions = 0.0d0
   GP_Adult_Population_Node_Type    = -9999
   GP_population_node_parameters    = 0.0d0 


   open( GP_restart_file_input_unit, file='GP_restart_file', &                                        
      form = 'formatted', access = 'sequential', &                                                  
      status = 'old' )                                 

! set Lprint so printing is done only under the conditions in the if-test

   !Lprint = .TRUE.   ! debug only
   Lprint = .FALSE. 

   if( i_GP_generation == 1                                  .or. &
     mod( i_GP_generation, GP_child_print_interval ) == 0  .or. &
     i_GP_generation == n_GP_generations                          )then
     Lprint = .TRUE.
   endif ! i_GP_generation == 1 .or. ...

   readloop:&
   do

   ! read the summary file header for each individual
   ! which has n_GP_parameters >= n_code_equations
    
    
      read(GP_restart_file_input_unit, *, iostat=istat) &
         i_GP_Gen, i_GP_indiv, &
         n_code_equations, n_trees, n_nodes, n_levels,  &
         GP_Adult_Population_SSE(i_GP_indiv)
             
      if( istat /= 0 ) exit readloop
    
    ! read initial conditions
    
      do  
    
         read(GP_restart_file_input_unit, '(A)', iostat=istat) Aline
    
         if( istat /= 0 )then
            exit readloop
         endif ! istat /=0 
    
         if( Aline(1:2) == '> '   ) exit
    
         read(Aline, *)&
              i_GP_Gen, i_GP_indiv, i_code_eq, &
              GP_Population_Initial_Conditions( i_code_eq, i_GP_indiv ) 
    
      enddo 
    !  read the node types from the old  summary file
        
      do 
    
         read(GP_restart_file_input_unit, '(A)',iostat=istat ) Aline
    
         if( istat /= 0 )then
            exit readloop
         endif ! istat /=0 
    
         if( Aline(1:2) == '> '   ) exit
    
         read(Aline, * ) &
             i_GP_Gen, i_GP_indiv,i_tree, i_node, &
             GP_Adult_Population_Node_Type(i_Node,i_Tree,i_GP_indiv)
    
      enddo 

    ! read all non-zero parameters from the old summary file file
    
      do 
    
         read(GP_restart_file_input_unit, '(A)',iostat=istat ) Aline
         if( istat /= 0 )then
            exit readloop
         endif ! istat /=0 
           
         if( Aline(1:2) == '>>' ) exit
    
         read(Aline,*) &
              i_GP_Gen, i_GP_indiv,i_tree, i_node, &
              GP_population_node_parameters( i_node,i_tree, i_GP_indiv)
    
     enddo  

   enddo readloop 

   close( GP_restart_file_input_unit  )

return

end subroutine read_all_summary_file
