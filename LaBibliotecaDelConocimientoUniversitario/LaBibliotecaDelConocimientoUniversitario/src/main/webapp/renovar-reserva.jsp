<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="config/conexion.jsp" %>
<%
    // Verificar autenticación
    if (session.getAttribute("usuario_id") == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    String reservaId = request.getParameter("id");
    
    if (reservaId != null) {
        Connection conn = null;
        CallableStatement cstmt = null;
        
        try {
            conn = getConnection();
            String sql = "{CALL renovar_reserva(?)}";
            cstmt = conn.prepareCall(sql);
            cstmt.setInt(1, Integer.parseInt(reservaId));
            
            cstmt.execute();
            
            String tipoUsuario = (String) session.getAttribute("tipo_usuario");
            if ("bibliotecario".equals(tipoUsuario)) {
                response.sendRedirect("panel-bibliotecario.jsp?success=renovacion");
            } else {
                response.sendRedirect("panel-usuario.jsp?success=renovacion");
            }
            
        } catch (Exception e) {
            String tipoUsuario = (String) session.getAttribute("tipo_usuario");
            if ("bibliotecario".equals(tipoUsuario)) {
                response.sendRedirect("panel-bibliotecario.jsp?error=" + e.getMessage());
            } else {
                response.sendRedirect("panel-usuario.jsp?error=" + e.getMessage());
            }
            
        } finally {
            try {
                if (cstmt != null) cstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        response.sendRedirect("panel-usuario.jsp");
    }
%>
