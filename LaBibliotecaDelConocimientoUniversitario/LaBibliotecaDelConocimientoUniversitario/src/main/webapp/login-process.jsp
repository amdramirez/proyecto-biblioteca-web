<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="config/conexion.jsp" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String tipoUsuario = request.getParameter("tipo");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = getConnection();
        
        if ("estudiante".equals(tipoUsuario)) {
            // Verificar usuario estudiante por correo electrónico y contraseña
            String sql = "SELECT u.usu_id, u.usu_nombre, u.usu_apellido, u.usu_fecha_naci, u.usu_contraseña, " +
                        "s.sed_nombre, c.car_nombre, uc.correo_usuario, ut.num_usuario " +
                        "FROM usuario u " +
                        "JOIN sede s ON u.cod_sede = s.cod_sede " +
                        "JOIN carrera c ON u.cod_carrera = c.cod_carrera " +
                        "JOIN usuario_correo uc ON u.usu_id = uc.usu_id " +
                        "LEFT JOIN usuario_telefono ut ON u.usu_id = ut.usu_id " +
                        "WHERE uc.correo_usuario = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String dbPassword = rs.getString("usu_contraseña");
                // Verificar contraseña (en producción usar hash)
                if (password.equals(dbPassword)) {
                    // Usuario autenticado - crear sesión completa
                    session.setAttribute("usuario_id", rs.getInt("usu_id"));
                    session.setAttribute("usuario_nombre", rs.getString("usu_nombre"));
                    session.setAttribute("usuario_apellido", rs.getString("usu_apellido"));
                    session.setAttribute("usuario_fecha_nacimiento", rs.getDate("usu_fecha_naci"));
                    session.setAttribute("usuario_sede", rs.getString("sed_nombre"));
                    session.setAttribute("usuario_carrera", rs.getString("car_nombre"));
                    session.setAttribute("usuario_email", rs.getString("correo_usuario"));
                    session.setAttribute("usuario_telefono", rs.getString("num_usuario"));
                    session.setAttribute("tipo_usuario", "estudiante");
                    
                    response.sendRedirect("panel-usuario.jsp?success=login");
                } else {
                    response.sendRedirect("login.html?error=contraseña_incorrecta");
                }
            } else {
                response.sendRedirect("login.html?error=usuario_no_encontrado");
            }
            
        } else if ("bibliotecario".equals(tipoUsuario)) {
            // Verificar bibliotecario por correo electrónico y contraseña
            String sql = "SELECT b.id_bibliotecario, b.bibli_nombre, b.bibli_apellido, b.bibli_contraseña, " +
                        "s.sed_nombre, bc.correo_bibli, bt.num_bibliotecario " +
                        "FROM bibliotecario b " +
                        "JOIN sede s ON b.cod_sede = s.cod_sede " +
                        "JOIN bibliotecario_correo bc ON b.id_bibliotecario = bc.id_bibliotecario " +
                        "LEFT JOIN bibliotecario_telefono bt ON b.id_bibliotecario = bt.id_bibliotecario " +
                        "WHERE bc.correo_bibli = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String dbPassword = rs.getString("bibli_contraseña");
                // Verificar contraseña (en producción usar hash)
                if (password.equals(dbPassword)) {
                    // Bibliotecario autenticado - crear sesión completa
                    session.setAttribute("usuario_id", rs.getInt("id_bibliotecario"));
                    session.setAttribute("usuario_nombre", rs.getString("bibli_nombre"));
                    session.setAttribute("usuario_apellido", rs.getString("bibli_apellido"));
                    session.setAttribute("usuario_sede", rs.getString("sed_nombre"));
                    session.setAttribute("usuario_email", rs.getString("correo_bibli"));
                    session.setAttribute("usuario_telefono", rs.getString("num_bibliotecario"));
                    session.setAttribute("tipo_usuario", "bibliotecario");
                    
                    response.sendRedirect("panel-bibliotecario.jsp?success=login");
                } else {
                    response.sendRedirect("login.html?error=contraseña_incorrecta");
                }
            } else {
                response.sendRedirect("login.html?error=bibliotecario_no_encontrado");
            }
        } else {
            response.sendRedirect("login.html?error=tipo_usuario_invalido");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("login.html?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    } finally {
        closeResources(conn, pstmt, rs);
    }
%>
