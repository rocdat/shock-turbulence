************************************************************************
*  Subroutine: Setup_Derivatives                                       
*                                                                      
*  Performs initialization for the derivative routines. This routine
*  must be called before any derivative is calculated. It is
*  responsible for defining the left hand matrix of the compact
*  difference scheme and performing LDU decomposition on them.         
************************************************************************
      Subroutine Setup_Derivatives_Asym

      Include 'header'

*  Locals
      Integer I, J, K
      Real*8  Work_x(Nx,Nx), Work_y(Ny,Ny), Work_z(Nz,Nz)

*  x,y and z- derivatives are optimized sixth order Pade with anti-symmetric
*  boundary conditions at one boundary face and reduced order of accuracy  
*  at the opposite boundaries
*  The anti-symmetric BCs are for derivatives of velocities normal to a plane
*  in spherical geometry
*
*  First derivative:
*
*  alpha * f'(I-1) + f'(I) + 
*
*  alpha * f'(I+1) 
*
*         [ f(I+2) - f(I-2) ]
*    =  b ---------------------
*                 4 h
*
*         [ f(I+1) - f(I-1) ]
*     + a ---------------------
*                 2 h
*
*  where
*
*    a   =   1.367577724399269  E+00
*    b   =   8.234281701082790  E-01
*  alpha =   5.381301488732363  E-01

      Do N = 1,LotX
       Do I = 1, Mx
        ldu_x_asym_A1(N,I) = alpha1_pade6
        ldu_x_asym_B1(N,I) =        1.0D0
        ldu_x_asym_C1(N,I) = alpha1_pade6
       End Do
      End Do

      Do N = 1,LotY
       Do J = 1, My
        ldu_y_asym_A1(N,J) = alpha1_pade6
        ldu_y_asym_B1(N,J) =        1.0D0
        ldu_y_asym_C1(N,J) = alpha1_pade6
       End Do
      End Do

      Do N = 1,LotZ
       Do K = 1, Mz
        ldu_z_asym_A1(N,K) = alpha1_pade6
        ldu_z_asym_B1(N,K) =        1.0D0
        ldu_z_asym_C1(N,K) = alpha1_pade6
       End Do
      End Do

*  First node is part of antisymmetric BC. The last node is third order accurate
*
*                                                     2 * f(4)      2 * f(3)     2 * f(2)
*  f'(1) + 2 * alpha * f'(2) + 2 * beta * f'(3)  =  c -------- + b  -------- + a --------
*                                                       6 h           4 h          2 h
*
*                      1     5                   1
*  f'(N) + 2 f'(N-1) = - [   - f(N) - 2 f(N-1) - - f(N-2) ]
*                      h     2                   2

      if(xrank .EQ. 0)then
       Do N = 1,LotX
        ldu_x_asym_A1(N,1) = 0.0D0
        ldu_x_asym_B1(N,1) = 1.0D0
        ldu_x_asym_C1(N,1) = 2D0 * alpha1_pade6
       End Do
      endif

      if(xrank .EQ. Px-1)then
       Do N = 1,LotX
        ldu_x_asym_A1(N,Mx) = 2.0D0
        ldu_x_asym_B1(N,Mx) = 1.0D0
        ldu_x_asym_C1(N,Mx) = 0.0D0
       End Do
      endif

      if(yrank .EQ. 0)then
       Do N = 1,LotY
        ldu_y_asym_A1(N,1) = 0.0D0
        ldu_y_asym_B1(N,1) = 1.0D0
        ldu_y_asym_C1(N,1) = 2D0 * alpha1_pade6
       End Do
      endif
 
      if(yrank .EQ. Py-1)then
       Do N = 1,LotY
        ldu_y_asym_A1(N,My) = 2.0D0
        ldu_y_asym_B1(N,My) = 1.0D0
        ldu_y_asym_C1(N,My) = 0.0D0
       End Do
      endif

      if(zrank .EQ. 0)then
       Do N = 1,LotZ
        ldu_z_asym_A1(N,1) = 0.0D0
        ldu_z_asym_B1(N,1) = 1.0D0
        ldu_z_asym_C1(N,1) = 2D0 * alpha1_pade6
       End Do
      endif

      if(zrank .EQ. Pz-1)then
       Do N = 1,LotZ
        ldu_z_asym_A1(N,Mz) = 2.0D0
        ldu_z_asym_B1(N,Mz) = 1.0D0
        ldu_z_asym_C1(N,Mz) = 0.0D0
       End Do
      endif


*  The second node is part of antisymmetric BC
*  The second to last node is fifth order accurate
*
*                                                
*  alpha * f'(1) + (1 + beta) * f'(2) + alpha * f'(3) + beta * f'(4)  =  
*                                                
*    f(5) + f(3)       f(4) + f(2)      f(3) - f(1)
*  c -----------  + b ------------- + a -----------                                
*        6 h              4 h               2 h 
*                                     
*
*  1                   1           1     5        1
*  - f'(N) + f'(N-1) + - f'(N-2) = - [   - f(N) + - f(N-1) - f(N-2)
*  6                   2           h     9        2
*
*                                        1
*                                      + -- f(N-3) ]
*                                        18
      if(xrank .EQ. 0)then
       Do N = 1,LotX
        ldu_x_asym_A1(N,2) = alpha1_pade6
        ldu_x_asym_B1(N,2) = 1.0D0
        ldu_x_asym_C1(N,2) = alpha1_pade6
       End Do
      endif


      if(xrank .EQ. Px-1)then
       Do N = 1,LotX
        ldu_x_asym_A1(N,Mx-1) = 1.0D0 / 2.0D0
        ldu_x_asym_B1(N,Mx-1) = 1.0D0
        ldu_x_asym_C1(N,Mx-1) = 1.0D0 / 6.0D0
       End Do
      endif


      if(yrank .EQ. 0)then
       Do N = 1,LotY
        ldu_y_asym_A1(N,2) = alpha1_pade6 
        ldu_y_asym_B1(N,2) = 1.0D0 
        ldu_y_asym_C1(N,2) = alpha1_pade6
       End Do
      endif

      if(yrank .EQ. Py-1)then
       Do N = 1,LotY
        ldu_y_asym_A1(N,My-1) = 1.0D0 / 2.0D0
        ldu_y_asym_B1(N,My-1) = 1.0D0
        ldu_y_asym_C1(N,My-1) = 1.0D0 / 6.0D0
       End Do
      endif

      if(zrank .EQ. 0)then
       Do N = 1,LotZ
        ldu_z_asym_A1(N,2) = alpha1_pade6 
        ldu_z_asym_B1(N,2) = 1.0D0 
        ldu_z_asym_C1(N,2) = alpha1_pade6
       End Do
      endif

      if(zrank .EQ. Pz-1)then
       Do N = 1,LotZ
        ldu_z_asym_A1(N,Mz-1) = 1.0D0 / 2.0D0
        ldu_z_asym_B1(N,Mz-1) = 1.0D0
        ldu_z_asym_C1(N,Mz-1) = 1.0D0 / 6.0D0
       End Do
      endif

**********************************************************************************

*  Second derivative:
*
*  beta * f''(I-2) + alpha * f''(I-1) + f''(I) + 
*
*  beta * f''(I+2) + alpha * f''(I+1) 
*
*         [ f(I+3) - 2 f(I) + f(I-3) ]
*    = c ------------------------------
*                    9 h^2
*
*         [ f(I+2) - 2 f(I) + f(I-2) ]
*    + b ------------------------------
*                    4 h^2
*
*         [ f(I+1) - 2 f(I) + f(I-1) ]
*    + a ------------------------------
*                     h^2
*
*  where
*
*    a   =   3.855624784762861  E-01
*    b   =   1.486194872274852  E+00
*    c   =   9.3303618061543067 E-02
*  alpha =   4.442052422604100  E-01
*   beta =   3.8325242145930416 E-02

      Do N = 1,LotX
       Do I = 1, Mx
        ldu_x_asym_A2(N,I) = alpha2_pade6
        ldu_x_asym_B2(N,I) =        1.0D0
        ldu_x_asym_C2(N,I) = alpha2_pade6
       End Do
      End Do

      Do N = 1,LotY
       Do J = 1, My
        ldu_y_asym_A2(N,J) = alpha2_pade6
        ldu_y_asym_B2(N,J) =        1.0D0
        ldu_y_asym_C2(N,J) = alpha2_pade6
       End Do
      End Do

      Do N = 1,LotZ
       Do K = 1, Mz
        ldu_z_asym_A2(N,K) = alpha2_pade6
        ldu_z_asym_B2(N,K) =        1.0D0
        ldu_z_asym_C2(N,K) = alpha2_pade6
       End Do
      End Do

*  The first node is part of antisymmetric BC and last node is third order accurate
*
*          
*    f"(1) = 0
*       
*                            1
*    f"(N)   + 11 f"(N-1) = --- [ 13 f(N) - 27 f(N-1) + 15 f(N-2)
*                           h^2
*
*                               - f(N-3) ]

      if(xrank .EQ. 0)then
       Do N = 1,LotX
        ldu_x_asym_A2(N,1) = 0.0D0
        ldu_x_asym_B2(N,1) = 1.0D0
        ldu_x_asym_C2(N,1) = 0.0D0
       End Do
      endif

      if(xrank .EQ. Px-1)then
       Do N = 1,LotX
        ldu_x_asym_A2(N,Mx) = 1.1D1
        ldu_x_asym_B2(N,Mx) = 1.0D0
        ldu_x_asym_C2(N,Mx) = 0.0D0
       End Do
      endif

      if(yrank .EQ. 0)then
       Do N = 1,LotY
        ldu_y_asym_A2(N,1) = 0.0D0
        ldu_y_asym_B2(N,1) = 1.0D0
        ldu_y_asym_C2(N,1) = 0.0D0
       End Do
      endif

      if(yrank .EQ. Py-1)then
       Do N = 1,LotY
        ldu_y_asym_A2(N,My) = 1.1D1
        ldu_y_asym_B2(N,My) = 1.0D0
        ldu_y_asym_C2(N,My) = 0.0D0
       End Do
      endif

      if(zrank .EQ. 0)then
       Do N = 1,LotZ
        ldu_z_asym_A2(N,1) = 0.0D0
        ldu_z_asym_B2(N,1) = 1.0D0
        ldu_z_asym_C2(N,1) = 0.0D0
       End Do
      endif

      if(zrank .EQ. Pz-1)then
       Do N = 1,LotZ
        ldu_z_asym_A2(N,Mz) = 1.1D1
        ldu_z_asym_B2(N,Mz) = 1.0D0
        ldu_z_asym_C2(N,Mz) = 0.0D0
       End Do
      endif

*  The second node is part of antisymmetric BC and second to last node is fifth order accurate
*
*                                            
*   alpha2 * f"(1) + (1 - beta2) * f"(2) + alpha2 * f"(3) + beta2 * f"(4)
*                                         
*                        f(5) - 2 f(2) - f(3)      f(4) - 3 f(2)      f(3) - 2 f(2)        
*                  = c2  -------------------- + b2 ------------- + c2 -------------
*                              9 h^2                   4 h^2               h^2
*
*
*   1                    7             1    99
*   -- f"(N) + f"(N-1) - -- f"(N-2) = --- [ -- f(N)   - 3 f(N-1)
*   10                   20           h^2   80
*
*                                           93          3
*                                         + -- f(N-2) - - f(N-3)
*                                           40          5
*
*                                           3
*                                         + -- f(N-4) ]
*                                           80
      if(xrank .EQ. 0)then
       Do N = 1,LotX
        ldu_x_asym_A2(N,2) =   alpha2_pade6
        ldu_x_asym_B2(N,2) =   1.0D0 
        ldu_x_asym_C2(N,2) =   alpha2_pade6
       End Do
      endif

 
      if(xrank .EQ. Px-1)then
       Do N = 1,LotX
        ldu_x_asym_A2(N,Mx-1) = - 7.0D0 / 2.0D1
        ldu_x_asym_B2(N,Mx-1) =   1.0D0
        ldu_x_asym_C2(N,Mx-1) =   1.0D-1
       End Do
      endif

      if(yrank .EQ. 0)then
       Do N = 1,LotY
        ldu_y_asym_A2(N,2) =   alpha2_pade6
        ldu_y_asym_B2(N,2) =   1.0D0 
        ldu_y_asym_C2(N,2) =   alpha2_pade6
       End Do
      endif

      if(yrank .EQ. Py-1)then
       Do N = 1,LotY
        ldu_y_asym_A2(N,My-1) = - 7.0D0 / 2.0D1
        ldu_y_asym_B2(N,My-1) =   1.0D0
        ldu_y_asym_C2(N,My-1) =   1.0D-1
       End Do
      endif

      if(zrank .EQ. 0)then
       Do N = 1,LotZ
        ldu_z_asym_A2(N,2) =   alpha2_pade6
        ldu_z_asym_B2(N,2) =   1.0D0 
        ldu_z_asym_C2(N,2) =   alpha2_pade6
       End Do
      endif

      if(zrank .EQ. Pz-1)then
       Do N = 1,LotZ
        ldu_z_asym_A2(N,Mz-1) = - 7.0D0 / 2.0D1
        ldu_z_asym_B2(N,Mz-1) =   1.0D0
        ldu_z_asym_C2(N,Mz-1) =   1.0D-1
       End Do
      endif

      End
************************************************************************
*  Subroutines: DFDX, DFDY, DFxzDZ, DFyzDZ (1st derivatives)
*               D2FDX2, D2FDY2, D2FxzDZ2, D2FyzDZ2 (2nd derivatives)
*
* These routines calculate the derivative of the scalar field F using
* compact difference schemes and assuming periodicity in all directions.
* They define the right hand vectors of the linear systems of
* equations resulting from the compact difference schemes. They then
* call a routine to solve the systems of equations.
*
* In: F (scalar field to be differentiated)
*     cadd (multiplicative factor)
*
* Out: dF, d2F: derivative of F
*
* Note: The x- and y-routines have the same structure but the
*       z-routines have not!
*
* z-Routines: The xz-versions are used where the processors hold entire
*             xz-planes whereas the yz-versions are used where the
*             processors store entire yz-planes.
*                                                                      
*  First derivatives                          
*  iadd = 0 : dF =       cadd * s1* df/ds
*  iadd = 1 : dF =  dF + cadd * s1* df/ds
*  Coupled derivatives:                                                
*  dF  = cadd * s1 * df/ds                                             
*  d2F = cadd * s2 * d2f/ds2                                           
*                                                                      
*  where                                                               
*    s1 = 1 / (dx_i/ds)                                                
*    s2 = s1 * s1                                                      
************************************************************************

************************************************************************

      Subroutine DFDX_asym(F, dF, iadd, cadd)

      Include 'header'
      Include 'mpif.h'

      Integer iadd
      Real*8  cadd
      Real*8  F(My,Mz,Mx), dF(My,Mz,Mx)
      Real*8  FP(My,Mz,2), FN(My,Mz,2)
      Real*8  W(LotX, Mx), W2(My,Mz,Mx)
      Real*8  temp(My,Mz,2,2)
      Integer status_arr(MPI_STATUS_SIZE,4), ierr, req(4)

*  Locals
      Integer I, J, K, N
      Real*8  fac

      fac = cadd * sx(1) * (Nx - 1)        ! NB: sx(1)*(Nx-1) = 1 / dx

* Putting first 3 and last 3 data planes into temp arrays for sending
      temp(:,:,:,1) = F(:,:,1:2)
      temp(:,:,:,2) = F(:,:,Mx-1:Mx)

* Taking care of boundary nodes
      if(xrank .EQ. 0)then
        source_right_x = MPI_PROC_NULL
        dest_left_x    = MPI_PROC_NULL
      elseif(xrank .EQ. Px-1)then
        source_left_x  = MPI_PROC_NULL
        dest_right_x   = MPI_PROC_NULL
      endif

* Transferring data from neighbouring processors
      Call MPI_IRECV(FP(1,1,1),    My*Mz*2, MPI_REAL8,source_right_x,
     .               source_right_x,                                 ! Recv last 3 planes
     .               MPI_XYZ_COMM, req(1), ierr)

      Call MPI_IRECV(FN(1,1,1),    My*Mz*2, MPI_REAL8,source_left_x,
     .               source_left_x,                                  ! Recv first 3 planes
     .               MPI_XYZ_COMM, req(2), ierr)

      Call MPI_ISEND(temp(1,1,1,2), My*Mz*2, MPI_REAL8,dest_right_x,
     .               rank,                                           ! Send last 3 planes
     .               MPI_XYZ_COMM, req(3), ierr)
      Call MPI_ISEND(temp(1,1,1,1), My*Mz*2, MPI_REAL8,dest_left_x,
     .               rank,                                           ! Send first 3 planes
     .               MPI_XYZ_COMM, req(4), ierr)


* Compute interior in the meantime
      Do J = 1, My
       Do K = 1, Mz
         Do I = 3, Mx-2
          N =  (J-1) * Mz + K
          W(N,I) = fac * (  b1_pade6 * ( F(J,K,I+2) - F(J,K,I-2) )  
     .                    + a1_pade6 * ( F(J,K,I+1) - F(J,K,I-1) ) )
         End Do
       End Do
      End Do

*  Wait to recieve planes
      Call MPI_WAITALL(4, req, status_arr, ierr)

      Do J = 1, My
        Do K = 1, Mz

          N =  (J-1) * Mz + K

          if(xrank .EQ. 0)then
           W(N,1) = fac * (b1_pade6 * ( F(J,K,3) + F(J,K,3) ) 
     .                   + a1_pade6 * ( F(J,K,2) + F(J,K,2) ) )
           W(N,2) = fac * (b1_pade6 * ( F(J,K,4) + F(J,K,2) )
     .                   + a1_pade6 * ( F(J,K,3) - F(J,K,1) ) )
          else
           W(N,1) = fac * (    b1_pade6 * ( F(J,K,3) - FP(J,K,1) ) 
     .                       + a1_pade6 * ( F(J,K,2) - FP(J,K,2) ) )
           W(N,2) = fac * (    b1_pade6 * ( F(J,K,4) - FP(J,K,2) ) 
     .                       + a1_pade6 * ( F(J,K,3) -  F(J,K,1) ) )
          endif
         End Do
      End Do

      Do J = 1, My
        Do K = 1, Mz

          N =  (J-1) * Mz + K

          if(xrank .EQ. Px-1)then
            W(N,Mx-1) = fac * (closure1 *   F(J,K,Mx)
     .                       + 5.0D-1   *   F(J,K,Mx-1)
     .                       -              F(J,K,Mx-2)
     .                       - closure2 *   F(J,K,Mx-3) )
            W(N,Mx)   = fac * ( 2.5D0    *   F(J,K,Mx)
     .                        - 2.0D0    *   F(J,K,Mx-1)
     .                        - 5.0D-1   *   F(J,K,Mx-2) )
          else
            W(N,Mx-1) = fac * (
     .                        b1_pade6 * ( FN(J,K,1)   - F(J,K,Mx-3) )
     .                      + a1_pade6 * ( F(J,K,Mx)   - F(J,K,Mx-2) ) )
            W(N,  Mx) = fac * (
     .                        b1_pade6 * ( FN(J,K,2)   - F(J,K,Mx-2) )
     .                      + a1_pade6 * ( FN(J,K,1)   - F(J,K,Mx-1) ) )
          endif
         End Do
      End Do
 
*  Solve the matrix system to obtain the derivative dF
      Call tridiagonal(ldu_x_asym_A1, ldu_x_asym_B1, ldu_x_asym_C1,
     .                 W, Mx, LotX, 0, MPI_X_COMM)

* Converting 2-D array to 3-D for copying
      Do N = 0,LotX-1
       Do I = 1,Mx
         J = N / Mz + 1
         K = MOD(N,Mz) + 1
         W2(J,K,I) = W(N+1,I)
       End Do
      End Do

      if(iadd .EQ. 0)Then
          dF = W2
      Else if(iadd .EQ. 1)Then
          dF = dF + W2
      End if

      End

************************************************************************
      Subroutine D2FDX2_asym(F, dF, d2F, iadd)

      Include 'header'
      Include 'mpif.h'

      Integer iadd
      Real*8  cadd
      Real*8  F(My,Mz,Mx), dF(My,Mz,Mx), d2F(My,Mz,Mx)
      Real*8  FP(My,Mz,2), FN(My,Mz,2)
      Real*8  W(LotX, Mx), W2(My,Mz,Mx)
      Real*8  temp(My,Mz,2,2)
      Integer status_arr(MPI_STATUS_SIZE,4), ierr, req(4)

*  Locals
      Integer I, J, K, N
      Real*8 fac

      fac = ((Nx - 1) * (Nx - 1)) * sx(2)

* Putting first 3 and last 3 data planes into temp arrays for sending
      temp(:,:,:,1) = F(:,:,1:2)
      temp(:,:,:,2) = F(:,:,Mx-1:Mx)

* Taking care of boundary nodes
      if(xrank .EQ. 0)then
        source_right_x = MPI_PROC_NULL
        dest_left_x    = MPI_PROC_NULL
      elseif(xrank .EQ. Px-1)then
        source_left_x  = MPI_PROC_NULL
        dest_right_x   = MPI_PROC_NULL
      endif

* Transferring data from neighbouring processors
      Call MPI_IRECV(FP(1,1,1),    My*Mz*2, MPI_REAL8,source_right_x,
     .                  source_right_x,                                 ! Recv last 3 planes
     .                  MPI_XYZ_COMM, req(1), ierr)

      Call MPI_IRECV(FN(1,1,1),    My*Mz*2, MPI_REAL8,source_left_x,
     .                  source_left_x,                                  ! Recv first 3 planes
     .                  MPI_XYZ_COMM, req(2), ierr)

      Call MPI_ISEND(temp(1,1,1,2), My*Mz*2, MPI_REAL8,dest_right_x,
     .               rank,                                           ! Send last 3 planes
     .               MPI_XYZ_COMM, req(3), ierr)

      Call MPI_ISEND(temp(1,1,1,1), My*Mz*2, MPI_REAL8,dest_left_x,
     .               rank,                                           ! Send first 3 planes
     .               MPI_XYZ_COMM, req(4), ierr)

* Compute interior in the meantime
      Do J = 1, My
        Do K = 1, Mz
          Do I = 3, Mx-2
            N =  (J-1) * Mz + K
            W(N,I) = fac *(     b2_pade6 * ( F(J,K,I+2) + F(J,K,I-2) ) +
     .                          a2_pade6 * ( F(J,K,I+1) + F(J,K,I-1) ) -
     .                          c2_pade6 *   F(J,K,I  ) )
          End Do
        End Do
      End Do

*  Wait to recieve last 3 planes
      Call MPI_WAITALL(4, req, status_arr, ierr)

      Do J = 1, My
        Do K = 1, Mz

          N =  (J-1) * Mz + K

          if(xrank .EQ. 0)then
           W(N,1) = 0D0
           W(N,2) = fac *( b2_pade6*(F(J,K,4)-3D0*F(J,K,2) )
     .                   + a2_pade6*(F(J,K,3)-2D0*F(J,K,2) ) )
          else
           W(N,1) = fac * ( b2_pade6 * ( F(J,K,3) + FP(J,K,1) ) + 
     .                      a2_pade6 * ( F(J,K,2) + FP(J,K,2) ) -
     .                      c2_pade6 *   F(J,K,1) )
           W(N,2) = fac * ( b2_pade6 * ( F(J,K,4) + FP(J,K,2) ) +
     .                      a2_pade6 * ( F(J,K,3) + F(J,K,1)  ) -
     .                      c2_pade6 *   F(J,K,2) )
          endif
        End Do
      End Do

      Do J = 1, My
        Do K = 1, Mz

          N =  (J-1) * Mz + K

          if(xrank .EQ. Px-1)then
          W(N,Mx-1) = fac * (1.2375D0 * F(J,K,Mx)
     .                    - 3.0D0    *  F(J,K,Mx-1)
     .                    + 2.325D0  *  F(J,K,Mx-2)
     .                    - 6.0D-1   *  F(J,K,Mx-3)
     .                    + 3.75D-2  *  F(J,K,Mx-4) )
          W(N,Mx) =   fac * (1.3D1   *  F(J,K,Mx)
     .                    - 2.7D1    *  F(J,K,Mx-1)
     .                    + 1.5D1    *  F(J,K,Mx-2)
     .                    -             F(J,K,Mx-3) )
          else
           W(N,Mx-1) = fac * (
     .                       b2_pade6 * ( FN(J,K,1) + F(J,K,Mx-3) ) +
     .                       a2_pade6 * ( F(J,K,Mx) + F(J,K,Mx-2) ) -
     .                       c2_pade6 *   F(J,K,Mx-1) )
           W(N,  Mx) = fac * (
     .                       b2_pade6 * ( FN(J,K,2) + F(J,K,Mx-2) ) +
     .                       a2_pade6 * ( FN(J,K,1) + F(J,K,Mx-1) ) -
     .                       c2_pade6 *   F(J,K,Mx) )
          endif
        End Do
      End Do

      if(iadd .EQ. 1) Call DFDX_asym(F,dF,0,1.0D0)

*  Solve the matrix system to obtain the derivative dF
      Call tridiagonal(ldu_x_asym_A2, ldu_x_asym_B2, ldu_x_asym_C2,
     .                 W, Mx, LotX, 0, MPI_X_COMM)

* Converting 2-D array to 3-D for copying
      Do N = 0,LotX-1
       Do I = 1,Mx
         J = N / Mz + 1
         K = MOD(N,Mz) + 1
         d2F(J,K,I) = W(N+1,I)
       End Do
      End Do

      End

************************************************************************
      Subroutine DFDY_asym(F, dF, iadd, cadd)

      Include 'header'
      Include 'mpif.h'

      Integer iadd
      Real*8  cadd
      Real*8  F(My,Mz,Mx), dF(My,Mz,Mx)
      Real*8  FP(2,Mz,Mx), FN(2,Mz,Mx)
      Real*8  W(LotY, My), W2(My,Mz,Mx)
      Real*8  temp(2,Mz,Mx,2)
      Integer status_arr(MPI_STATUS_SIZE,4), ierr, req(4)

*  Locals
      Integer I, J, K, N
      Real*8  fac

      fac = cadd * sy(1) * (Ny - 1)

      temp(:,:,:,1) = F(1:2,:,:)
      temp(:,:,:,2) = F(My-1:My,:,:)

* Taking care of boundary nodes
      if(yrank .EQ. 0)then
        source_right_y = MPI_PROC_NULL
        dest_left_y    = MPI_PROC_NULL
      elseif(yrank .EQ. Py-1)then
        source_left_y  = MPI_PROC_NULL
        dest_right_y   = MPI_PROC_NULL
      endif

* Transferring data from neighbouring processors
      Call MPI_IRECV(FP(1,1,1),    Mz*Mx*2, MPI_REAL8,source_right_y,
     .               source_right_y,                                 ! Recv last 3 planes
     .               MPI_XYZ_COMM, req(1), ierr)

      Call MPI_IRECV(FN(1,1,1),    Mz*Mx*2, MPI_REAL8,source_left_y ,
     .               source_left_y,                                  ! Recv first 3 planes
     .               MPI_XYZ_COMM, req(2), ierr)

      Call MPI_ISEND(temp(1,1,1,2), Mz*Mx*2, MPI_REAL8,dest_right_y,
     .               rank,                                           ! Send last 3 planes
     .               MPI_XYZ_COMM, req(3), ierr)

      Call MPI_ISEND(temp(1,1,1,1), Mz*Mx*2, MPI_REAL8,dest_left_y,
     .               rank,                                           ! Send first 3 planes
     .               MPI_XYZ_COMM, req(4), ierr)

* Compute interior in the meantime
      Do I = 1, Mx
        Do K = 1, Mz
          N =  (I-1) * Mz + K
          Do J = 3, My-2
            W(N,J) = fac * (    b1_pade6 * ( F(J+2,K,I) - F(J-2,K,I) ) 
     .                        + a1_pade6 * ( F(J+1,K,I) - F(J-1,K,I) ) )
          End Do
        End Do
      End Do

*  Wait to recieve planes
      Call MPI_WAITALL(4, req, status_arr, ierr)

      Do I = 1, Mx
        Do K = 1, Mz

          N =  (I-1) * Mz + K

          if(yrank .EQ. 0)then
           W(N,1) = fac * (b1_pade6 * ( F(3,K,I) + F(3,K,I) )
     .                  + a1_pade6 * ( F(2,K,I) + F(2,K,I) ) )
           W(N,2) = fac * ( b1_pade6 * ( F(4,K,I) + F(2,K,I) )
     .                  + a1_pade6 * ( F(3,K,I) - F(1,K,I) ) )
          else        
           W(N,1) = fac * ( b1_pade6 * ( F(3,K,I) - FP(1,K,I) ) 
     .                    + a1_pade6 * ( F(2,K,I) - FP(2,K,I) ) )
           W(N,2) = fac * ( b1_pade6 * ( F(4,K,I) - FP(2,K,I) )
     .                    + a1_pade6 * ( F(3,K,I) -  F(1,K,I) ) )
          endif
        End Do
      End Do

      Do I = 1, Mx
        Do K = 1, Mz

          N =  (I-1) * Mz + K

          if(yrank .EQ. Py-1)then
            W(N,My-1) = fac * ( closure1 *   F(My,  K,I)
     .                        + 5.0D-1   *   F(My-1,K,I)
     .                        -              F(My-2,K,I)
     .                        - closure2 *   F(My-3,K,I) )
            W(N,My) = fac * ( 2.5D0    *   F(My,  K,I)
     .                      - 2.0D0    *   F(My-1,K,I)
     .                      - 5.0D-1   *   F(My-2,K,I) )
          else
            W(N,My-1) = fac * (
     .                        b1_pade6 * ( FN(1,K,I) - F(My-3,K,I) )
     .                      + a1_pade6 * ( F(My,K,I) - F(My-2,K,I) ) )
            W(N,  My) = fac * (
     .                        b1_pade6 * ( FN(2,K,I) - F(My-2,K,I) )
     .                      + a1_pade6 * ( FN(1,K,I) - F(My-1,K,I) ) )
          endif
        End Do
      End Do

*  Solve the matrix system to obtain the derivative dF
      Call tridiagonal(ldu_y_asym_A1, ldu_y_asym_B1, ldu_y_asym_C1,
     .                 W, My, LotY, 0, MPI_Y_COMM)

* Converting 2-D array to 3-D for copying
      Do N = 0,LotY-1
       Do J = 1,My
         I = N / Mz + 1
         K = MOD(N,Mz) + 1
         W2(J,K,I) = W(N+1,J)
       End Do
      End Do

* Copying solution array to output matrix
      if(iadd .EQ. 0)Then
          dF = W2
      Else if(iadd .EQ. 1)Then
          dF = dF + W2
      End if
      
      End

************************************************************************
      Subroutine D2FDY2_asym(F, dF, d2F, iadd)

      Include 'header'
      Include 'mpif.h'

      Integer iadd
      Real*8 cadd
      Real*8  F(My,Mz,Mx), dF(My,Mz,Mx), d2F(My,Mz,Mx)
      Real*8  FP(2,Mz,Mx), FN(2,Mz,Mx)
      Real*8  W(LotY, My), W2(My,Mz,Mx)
      Real*8  temp(2,Mz,Mx,2)
      Integer status_arr(MPI_STATUS_SIZE,4), ierr, req(4)

*  Locals
      Integer I, J, K, N
      Real*8  fac

      fac  = ((Ny - 1) * (Ny - 1)) * sy(2)

      temp(:,:,:,1) = F(1:2,:,:)
      temp(:,:,:,2) = F(My-1:My,:,:)

* Taking care of boundary nodes
      if(yrank .EQ. 0)then
        source_right_y = MPI_PROC_NULL
        dest_left_y    = MPI_PROC_NULL
      elseif(yrank .EQ. Py-1)then
        source_left_y  = MPI_PROC_NULL
        dest_right_y   = MPI_PROC_NULL
      endif

* Transferring data from neighbouring processors
      Call MPI_IRECV(FP(1,1,1),    Mz*Mx*2, MPI_REAL8,source_right_y,
     .               source_right_y,                                 ! Recv last 3 planes
     .               MPI_XYZ_COMM, req(1), ierr)

      Call MPI_IRECV(FN(1,1,1),    Mz*Mx*2, MPI_REAL8,source_left_y ,
     .               source_left_y,                                  ! Recv first 3 planes
     .               MPI_XYZ_COMM, req(2), ierr)

      Call MPI_ISEND(temp(1,1,1,2), Mz*Mx*2, MPI_REAL8,dest_right_y,
     .               rank,                                           ! Send last 3 planes
     .               MPI_XYZ_COMM, req(3), ierr)
      Call MPI_ISEND(temp(1,1,1,1), Mz*Mx*2, MPI_REAL8,dest_left_y,
     .               rank,                                           ! Send first 3 planes
     .               MPI_XYZ_COMM, req(4), ierr)

* Compute interior in the meantime
      Do I = 1, Mx
        Do K = 1, Mz
          N =  (I-1) * Mz + K
          Do J = 3, My-2
            W(N,J) = fac *( b2_pade6 * ( F(J+2,K,I) + F(J-2,K,I) ) +
     .                      a2_pade6 * ( F(J+1,K,I) + F(J-1,K,I) ) -
     .                      c2_pade6 *   F(J,K,I) )
          End Do
        End Do
      End Do

*  Wait to recieve planes
      Call MPI_WAITALL(4, req, status_arr, ierr)

      Do I = 1, Mx
        Do K = 1, Mz

          N =  (I-1) * Mz + K

          if(yrank .EQ. 0)then
           W(N,1) = 0D0
           W(N,2) = fac * (b2_pade6*(F(4,K,I)-3D0*F(2,K,I) )
     .                   + a2_pade6*(F(3,K,I)-2D0*F(2,K,I)) ) 

          else
           W(N,1) = fac * ( b2_pade6 * ( F(3,K,I) + FP(1,K,I) ) + 
     .                      a2_pade6 * ( F(2,K,I) + FP(2,K,I) ) -
     .                      c2_pade6 *   F(1,K,I) )
           W(N,2) = fac * ( b2_pade6 * ( F(4,K,I) + FP(2,K,I) ) + 
     .                      a2_pade6 * ( F(3,K,I) + F(1,K,I)  ) -
     .                      c2_pade6 *   F(2,K,I) )
           W(N,3) = fac * ( b2_pade6 * ( F(5,K,I) + F(1,K,I)  ) + 
     .                      a2_pade6 * ( F(4,K,I) + F(2,K,I)  ) -
     .                      c2_pade6 *   F(3,K,I) )
          endif
        End Do
      End Do

      Do I = 1, Mx
        Do K = 1, Mz

          N =  (I-1) * Mz + K

          if(yrank .EQ. Py-1)then
           W(N,My-1) = fac * (1.2375D0 * F(My,  K,I)
     .                      - 3.0D0    * F(My-1,K,I)
     .                      + 2.325D0  * F(My-2,K,I)
     .                      - 6.0D-1   * F(My-3,K,I)
     .                      + 3.75D-2  * F(My-4,K,I) )
           W(N,My)   = fac * (1.3D1    * F(My,  K,I)
     .                     - 2.7D1     * F(My-1,K,I)
     .                     + 1.5D1     * F(My-2,K,I)
     .                     -             F(My-3,K,I) )
          else
           W(N,My-1) = fac * (
     .                        b2_pade6 * ( FN(1,K,I) + F(My-3,K,I) ) +
     .                        a2_pade6 * ( F(My,K,I) + F(My-2,K,I) ) -
     .                        c2_pade6 *   F(My-1,K,I) )
           W(N,  My) = fac * (
     .                        b2_pade6 * ( FN(2,K,I) + F(My-2,K,I) ) +
     .                        a2_pade6 * ( FN(1,K,I) + F(My-1,K,I) ) -
     .                        c2_pade6 *   F(My,K,I) )
          endif
        End Do
      End Do

      if(iadd .EQ. 1) Call DFDY_asym(F,dF,0,1.0D0)

*  Solve the matrix system to obtain the derivative dF
      Call tridiagonal(ldu_y_asym_A2, ldu_y_asym_B2, ldu_y_asym_C2,
     .                 W, My, LotY, 0, MPI_Y_COMM)

* Converting 2-D array to 3-D for copying
      Do N = 0,LotY-1
       Do J = 1,My
         I = N / Mz + 1
         K = MOD(N,Mz) + 1
         d2F(J,K,I) = W(N+1,J)
       End Do
      End Do

      End

************************************************************************
      Subroutine DFDZ_asym(F, dF, iadd, cadd)

      Include 'header'
      Include 'mpif.h'

      Integer iadd
      Real*8  cadd
      Real*8  F(My,Mz,Mx), dF(My,Mz,Mx)
      Real*8  FP(My,2,Mx), FN(My,2,Mx)
      Real*8  W(LotZ, Mz), W2(My,Mz,Mx)
      Real*8  temp(My,2,Mx,2)
      Integer status_arr(MPI_STATUS_SIZE,4), ierr, req(4)

*  Locals
      Integer I, J, K, N
      Real*8  fac

      fac = cadd * sz(1) * (Nz - 1)

* Putting first 3 and last 3 data planes into temp arrays for sending
      temp(:,:,:,1) = F(:,1:2,:)
      temp(:,:,:,2) = F(:,Mz-1:Mz,:)

* Taking care of boundary nodes
      if(zrank .EQ. 0)then
        source_right_z = MPI_PROC_NULL
        dest_left_z    = MPI_PROC_NULL
      elseif(zrank .EQ. Pz-1)then
        source_left_z  = MPI_PROC_NULL
        dest_right_z   = MPI_PROC_NULL
      endif

* Transferring data from neighbouring processors
      Call MPI_IRECV(FP(1,1,1),    Mx*My*2, MPI_REAL8,source_right_z,
     .               source_right_z,                                 ! Recv last 3 planes
     .               MPI_XYZ_COMM, req(1), ierr)

      Call MPI_IRECV(FN(1,1,1),    Mx*My*2, MPI_REAL8,source_left_z,
     .               source_left_z,                                  ! Recv first 3 planes
     .               MPI_XYZ_COMM, req(2), ierr)

      Call MPI_ISEND(temp(1,1,1,2), Mx*My*2, MPI_REAL8,dest_right_z,
     .               rank,                                           ! Send last 3 planes
     .               MPI_XYZ_COMM, req(3), ierr)

      Call MPI_ISEND(temp(1,1,1,1), Mx*My*2, MPI_REAL8,dest_left_z,
     .               rank,                                           ! Send first 3 planes
     .               MPI_XYZ_COMM, req(4), ierr)

* Compute interior in the meantime
      Do I = 1, Mx
        Do J = 1, My
          N =  (I-1) * My + J
          Do K = 3, Mz-2
            W(N,K) = fac * ( b1_pade6 * ( F(J,K+2,I) - F(J,K-2,I) )
     .                    +  a1_pade6 * ( F(J,K+1,I) - F(J,K-1,I) ) )
          End Do
        End Do
      End Do

*  Wait to recieve last 3 planes
      Call MPI_WAITALL(4, req, status_arr, ierr)

      Do I = 1, Mx
        Do J = 1, My

          N =  (I-1) * My + J

          if(zrank .EQ. 0)then
           W(N,1) = fac * (b1_pade6 * ( F(J,3,I) + F(J,3,I) )
     .                   + a1_pade6 * ( F(J,2,I) + F(J,2,I) ) )

           W(N,2) = fac * (b1_pade6 * ( F(J,4,I) + F(J,2,I) )
     .                   + a1_pade6 * ( F(J,3,I) - F(J,1,I) ) )

          else
           W(N,1) = fac * ( b1_pade6 * ( F(J,3,I) - FP(J,1,I) ) 
     .                   +  a1_pade6 * ( F(J,2,I) - FP(J,2,I) ) )
           W(N,2) = fac * ( b1_pade6 * ( F(J,4,I) - FP(J,2,I) ) 
     .                   +  a1_pade6 * ( F(J,3,I) -  F(J,1,I) ) )
          endif
        End Do
      End Do

      Do I = 1, Mx
        Do J = 1, My

          N =  (I-1) * My + J

          if(zrank .EQ. Pz-1)then
            W(N,Mz-1) = fac * ( closure1 *   F(J,Mz,  I)
     .                    + 5.0D-1   *   F(J,Mz-1,I)
     .                    -              F(J,Mz-2,I)
     .                    - closure2 *   F(J,Mz-3,I) )
            W(N,Mz) = fac * (  2.5D0    *   F(J,Mz,  I)
     .                       - 2.0D0    *   F(J,Mz-1,I)
     .                       - 5.0D-1   *   F(J,Mz-2,I) )
          else
            W(N,Mz-1) = fac * (
     .                         b1_pade6 * ( FN(J,1,I) - F(J,Mz-3,I) )
     .                       + a1_pade6 * ( F(J,Mz,I) - F(J,Mz-2,I) ) )
            W(N,  Mz) = fac * (
     .                         b1_pade6 * ( FN(J,2,I) - F(J,Mz-2,I) )
     .                       + a1_pade6 * ( FN(J,1,I) - F(J,Mz-1,I) ) )
          endif
        End Do
      End Do

*  Solve the matrix system to obtain the derivative dF
      Call tridiagonal(ldu_z_asym_A1, ldu_z_asym_B1, ldu_z_asym_C1,
     .                 W, Mz, LotZ, 0, MPI_Z_COMM)

* Converting 2-D array to 3-D for copying
      Do N = 0,LotZ-1
       Do K = 1,Mz
         I = N / My + 1
         J = MOD(N,My) + 1
         W2(J,K,I) = W(N+1,K)
       End Do
      End Do

* Copying solution array to output matrix
      if(iadd .EQ. 0)Then
          dF = W2
      Else if(iadd .EQ. 1)Then
          dF = dF + W2
      End if

      End

************************************************************************
      Subroutine D2FDZ2_asym(F, dF, d2F, iadd)

      Include 'header'
      Include 'mpif.h'

      Integer iadd
      Real*8  cadd
      Real*8  F(My,Mz,Mx), dF(My,Mz,Mx), d2F(My,Mz,Mx)
      Real*8  FP(My,2,Mx), FN(My,2,Mx)
      Real*8  W(LotZ, Mz), W2(My,Mz,Mx)
      Real*8  temp(My,2,Mx,2)
      Integer status_arr(MPI_STATUS_SIZE,4), ierr, req(4)

*  Locals
      Integer I, J, K, N
      Real*8  fac

      fac = ((Nz - 1) * (Nz - 1)) * sz(2)

* Putting first 3 and last 3 data planes into temp arrays for sending
      temp(:,:,:,1) = F(:,1:2,:)
      temp(:,:,:,2) = F(:,Mz-1:Mz,:)

* Taking care of boundary nodes
      if(zrank .EQ. 0)then
        source_right_z = MPI_PROC_NULL
        dest_left_z    = MPI_PROC_NULL
      elseif(zrank .EQ. Pz-1)then
        source_left_z  = MPI_PROC_NULL
        dest_right_z   = MPI_PROC_NULL
      endif

* Transferring data from neighbouring processors
      Call MPI_IRECV(FP(1,1,1),    Mx*My*2, MPI_REAL8,source_right_z,
     .                  source_right_z,                                 ! Recv last 3 planes
     .                  MPI_XYZ_COMM, req(1), ierr)

      Call MPI_IRECV(FN(1,1,1),    Mx*My*2, MPI_REAL8,source_left_z,
     .                  source_left_z,                                  ! Recv first 3 planes
     .                  MPI_XYZ_COMM, req(2), ierr)

      Call MPI_ISEND(temp(1,1,1,2), Mx*My*2, MPI_REAL8,dest_right_z,
     .                  rank,                                           ! Send last 3 planes
     .               MPI_XYZ_COMM, req(3), ierr)

      Call MPI_ISEND(temp(1,1,1,1), Mx*My*2, MPI_REAL8,dest_left_z,
     .                  rank,                                           ! Send first 3 planes
     .               MPI_XYZ_COMM, req(4), ierr)

* Compute interior in the meantime
      Do I = 1, Mx
        Do J = 1, My
          N =  (I-1) * My + J
          Do K = 3, Mz-2
            W(N,K) = fac * ( b2_pade6 * ( F(J,K+2,I) + F(J,K-2,I) ) +
     .                       a2_pade6 * ( F(J,K+1,I) + F(J,K-1,I) ) -
     .                       c2_pade6 *   F(J,K,  I) )
          End Do
        End Do
      End Do

*  Wait to recieve planes
      Call MPI_WAITALL(4, req, status_arr, ierr)

      Do I = 1, Mx
        Do J = 1, My

          N =  (I-1) * My + J

          if(zrank .EQ. 0)then
           W(N,1) = 0D0
           W(N,2) = fac * (b2_pade6*(F(J,4,I)-3D0*F(J,2,I) )
     .                   + a2_pade6*(F(J,3,I)-2D0*F(J,2,I) ) )
          else
           W(N,1) = fac * ( b2_pade6 * ( F(J,3,I) + FP(J,1,I) ) + 
     .                      a2_pade6 * ( F(J,2,I) + FP(J,2,I) ) -
     .                      c2_pade6 *   F(J,1,I) )
           W(N,2) = fac * ( b2_pade6 * ( F(J,4,I) + FP(J,2,I) ) + 
     .                      a2_pade6 * ( F(J,3,I) + F(J,1,I)  ) -
     .                      c2_pade6 *   F(J,2,I) )
          endif
        End Do
      End Do

      Do I = 1, Mx
        Do J = 1, My

          N =  (I-1) * My + J

          if(zrank .EQ. Pz-1)then
           W(N,Mz-1) = fac * (1.2375D0 * F(J,Mz,  I)
     .                      - 3.0D0    * F(J,Mz-1,I)
     .                      + 2.325D0  * F(J,Mz-2,I)
     .                      - 6.0D-1   * F(J,Mz-3,I)
     .                      + 3.75D-2  * F(J,Mz-4,I) )
           W(N,Mz)  =  fac * (1.3D1    * F(J,Mz,  I)
     .                      - 2.7D1    * F(J,Mz-1,I)
     .                      + 1.5D1    * F(J,Mz-2,I)
     .                      -            F(J,Mz-3,I) )
         else
          W(N,Mz-1) = fac * (
     .                       b2_pade6 * ( FN(J,1,   I) + F(J,Mz-3,I) ) +
     .                       a2_pade6 * ( F(J,Mz,  I) + F(J,Mz-2,I) ) -
     .                       c2_pade6 *   F(J,Mz-1,I) )
          W(N,  Mz) = fac * (
     .                       b2_pade6 * ( FN(J,2,   I) + F(J,Mz-2,I) ) +
     .                       a2_pade6 * ( FN(J,1,   I) + F(J,Mz-1,I) ) -
     .                       c2_pade6 *   F(J,Mz,  I) )
         endif
        End Do
      End Do

      if(iadd .EQ. 1) Call DFDZ_asym(F, dF, 0, 1.0D0)

*  Solve the matrix system to obtain the derivative dF
      Call tridiagonal(ldu_z_asym_A2, ldu_z_asym_B2, ldu_z_asym_C2,
     .                 W, Mz, LotZ, 0, MPI_Z_COMM)

* Converting 2-D array to 3-D for copying
      Do N = 0,LotZ-1
       Do K = 1,Mz
         I = N / My + 1
         J = MOD(N,My) + 1
         d2F(J,K,I) = W(N+1,K)
       End Do
      End Do

      End
