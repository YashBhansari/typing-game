package com.typinggame.servlet;

import com.typinggame.dao.UserDAO;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;

@WebServlet("/AuthServlet")
public class AuthServlet extends HttpServlet
{
	private static final long serialVersionUID = 1L;

	protected void do_post(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        String action = request.getParameter("action");

        if ("register".equals(action))
        {
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            boolean success = UserDAO.register_user(username, email, password);
            if (success)
            {
                response.sendRedirect("login.jsp");
            }
            else
            {
                response.sendRedirect("register.jsp?error=1");
            }
        }
        else if ("login".equals(action))
        {
            String email = request.getParameter("email");
            String password = request.getParameter("password");            

            boolean valid = UserDAO.validate_user(email, password);
            if (valid)
            {
                HttpSession session = request.getSession();
                session.setAttribute("email", email);
                String username = UserDAO.get_username_by_email(email);
                int user_id = UserDAO.get_user_id_by_email(email);
                session.setAttribute("username", username);
                session.setAttribute("user_id", user_id);
                response.sendRedirect("home.jsp");
            }
            else
            {
                response.sendRedirect("login.jsp?error=1");
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        do_post(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        do_post(request, response);
    }
}
