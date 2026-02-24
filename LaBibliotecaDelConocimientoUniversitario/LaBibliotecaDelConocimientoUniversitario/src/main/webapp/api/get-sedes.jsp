<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="../config/conexion.jsp" %>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = getConnection();
        String sql = "SELECT cod_sede, sed_nombre FROM sede ORDER BY sed_nombre";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            out.println("<option value='" + rs.getInt("cod_sede") + "'>" + 
                       rs.getString("sed_nombre") + "</option>");
        }
        
    } catch (Exception e) {
        out.println("<option value=''>Error al cargar sedes</option>");
        e.printStackTrace();
    } finally {
        closeResources(conn, pstmt, rs);
    }
%>
