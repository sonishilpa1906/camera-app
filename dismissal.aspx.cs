using BLL.District;
using BLL.Login;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using DAL;
using BLL;
using System.IO;

namespace WebSite.Pages.SEM
{
    public partial class dismissal : SecuredPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                try
                {
                    if (SessionKeys.User != null)
                    {
                        if (SessionKeys.User.Role == Enumeration.UserType.SA)  //no school selection
                        {
                            SetSingleSchoolValues(SessionKeys.User.SchoolID, Convert.ToString(SessionKeys.User.SchoolName));
                        }
                        else
                        {
                            List<SCHOOL> lstEmergencySchools = SchoolBLL.GetMultipleSchoolEmergency(SessionKeys.User.Role, SessionKeys.User.DistrictID, Convert.ToString(Session["LoggedInUserAdultID"]));

                            if (lstEmergencySchools.Count > 1) //if multiple schools are in emergency
                            {
                                ShowPanel(panelSelectSchool);
                                Session["EmergencySchools"] = lstEmergencySchools;
                            }
                            else //no school selection
                            {
                                if (lstEmergencySchools.FirstOrDefault() != null)
                                {
                                    SetSingleSchoolValues(lstEmergencySchools.FirstOrDefault().ID.ToString(), lstEmergencySchools.FirstOrDefault().NAME);
                                }
                            }
                        }
                    }
                    else
                        Response.Redirect("~/Default.aspx", true);
                }
                catch (Exception ex)
                {
                    ErrorBLL.Insert(ex, "page load: " + SessionKeys.User.UserId);
                }
            }
        }

        private void SetSingleSchoolValues(string schoolid, string schoolname)
        {
            try
            {
                hdnSelectedSchoolId.Value = schoolid;

                int parentCount = SchoolParentCount(hdnSelectedSchoolId.Value);
                hdnParentCount.Value = Convert.ToString(parentCount);


                SetElementVisibility(lblSelectedSchool, true);
                lblSelectedSchool.Text = txtSchool.Text = schoolname;

                if (parentCount == 0)
                {
                    ShowPanel(panelSelectParentPicture);
                    SetElementVisibility(btnBackParentPicture, false);
                    ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "TakeParentPhoto();", true);
                }
                else
                {
                    ShowPanel(panelSelectParent);
                    SetElementVisibility(btnBackSelectParent, false);
                }
            }
            catch (Exception ex)
            {
                ErrorBLL.Insert(ex, "SetSingleSchoolValues: schoolid " + schoolid + ", userid: " + SessionKeys.User.UserId);
            }
        }

        [WebMethod]
        public static string GetParents(string term, string schoolid)
        {
            List<PersonNameForDropDown> lstParents = new List<PersonNameForDropDown>();
            try
            {
                var adults = AdultBLL.GetAdultsByRole(Enumeration.AdultRoleEnum.PG.ToString(), schoolid, SessionKeys.User.DistrictID);
                if (adults != null)
                {
                    lstParents = adults.Select(a => new PersonNameForDropDown { Text = a.LASTNAME + ", " + a.FIRSTNAME, Value = Convert.ToString(a.ID) }).ToList();
                    if (!string.IsNullOrEmpty(term))
                        lstParents = lstParents.Where(a => a.Text.ToLower().StartsWith(term.ToLower())).ToList();
                }
            }
            catch (Exception ex)
            {
                ErrorBLL.Insert(ex, "GetParents > term:" + term + ", schoolid:" + schoolid + ", userid: " + SessionKeys.User.UserId);
            }
            string json = new JavaScriptSerializer().Serialize(lstParents);
            return json;
        }

        [WebMethod]
        public static int SchoolParentCount(string schoolid)
        {
            List<ADULT> pgAdults = AdultBLL.GetAdultsByRole(Enumeration.AdultRoleEnum.PG.ToString(), schoolid, SessionKeys.User.DistrictID).ToList();
            return pgAdults.Count;
        }

        [WebMethod]
        public static string GetSchools(string term)
        {
            List<PersonNameForDropDown> lstSchools = new List<PersonNameForDropDown>();
            try
            {
                var schools = (List<SCHOOL>)HttpContext.Current.Session["EmergencySchools"];
                if (schools != null)
                {
                    lstSchools = schools.Select(a => new PersonNameForDropDown { Text = a.NAME, Value = a.ID.ToString() }).ToList();

                    if (!string.IsNullOrEmpty(term))
                        lstSchools = lstSchools.Where(a => a.Text.ToLower().StartsWith(term.ToLower())).ToList();
                }
            }
            catch (Exception ex)
            {
                ErrorBLL.Insert(ex, "GetSchools > term:" + term + ", userid: " + SessionKeys.User.UserId);
            }
            string json = new JavaScriptSerializer().Serialize(lstSchools);
            return json;
        }

        [WebMethod]
        public static string GetStudents(string term, string schoolid)
        {
            List<GetStudentsToDismissResult> lstStudents = ActionBLL.GetStudentsToDismiss(schoolid, term, null);
            string json = new JavaScriptSerializer().Serialize(lstStudents);
            return json;
        }

        private void ShowPanel(Panel PANEL_TO_SHOW)
        {
            panelSelectSchool.CssClass = "displayNone";
            panelSelectParent.CssClass = "displayNone";
            panelSelectParentPicture.CssClass = "displayNone";
            panelTakeParentIdPicture.CssClass = "displayNone";
            panelSelectStudent.CssClass = "displayNone";
            panelStudentsPicklist.CssClass = "displayNone";
            panelDismissToSameParent.CssClass = "displayNone";

            PANEL_TO_SHOW.CssClass = "displayBlock";
            lblSelectedSchool.Text = txtSchool.Text;
            if (PANEL_TO_SHOW.ID == "panelSelectSchool")
                lblSelectedSchool.Text = "";
        }

        private void SetElementVisibility(WebControl control, bool isShow)
        {
            string existingClass = control.CssClass;
            if (!string.IsNullOrEmpty(existingClass))
            {
                if (existingClass.Contains("displayBlock"))
                    existingClass = existingClass.Replace("displayBlock", "");
                else if (existingClass.Contains("displayNone"))
                    existingClass = existingClass.Replace("displayNone", "");
            }
            control.CssClass = isShow ? existingClass + " displayBlock" : existingClass + " displayNone";
        }

        protected void btnBackSelectParent_Click(object sender, EventArgs e)
        {
            ShowPanel(panelSelectSchool);
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "LoadSchools();", true);
        }

        protected void btnNextSelectSchool_Click(object sender, EventArgs e)
        {
            ShowPanel(panelSelectParent);
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "LoadParents();", true);
        }

        protected void btnNextSelectParent_Click(object sender, EventArgs e)
        {
            ShowPanel(panelSelectParentPicture);
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "TakeParentPhoto();", true);
        }

        protected void btnBackParentPicture_Click(object sender, EventArgs e)
        {
            string parentCount = hdnParentCount.Value;
            if (parentCount == "0")
            {
                ShowPanel(panelSelectSchool);
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "LoadSchools();", true);
            }
            else
            {
                ShowPanel(panelSelectParent);
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "LoadParents();", true);
            }
        }

        protected void btnNextParentPicture_Click(object sender, EventArgs e)
        {
            try
            {
                ShowPanel(panelTakeParentIdPicture);
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "TakeParentIdPhoto();", true);
            }
            catch (Exception ex)
            {
                ErrorBLL.Insert(ex, "btnNextParentPicture_Click > userid: " + SessionKeys.User.UserId);
            }
        }

        protected void btnBackParentIdPicture_Click(object sender, EventArgs e)
        {
            ShowPanel(panelSelectParentPicture);
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "TakeParentPhoto();", true);
        }

        protected void btnNextParentIdPicture_Click(object sender, EventArgs e)
        {
            try
            {
                string parentCount = hdnParentCount.Value;
                //if school has no parent
                if (parentCount == "0" || string.IsNullOrEmpty(hdnSelectedParentId.Value))
                {
                    ShowPanel(panelStudentsPicklist);
                    ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "LoadStudents();", true);
                }
                else
                {
                    List<GetStudentsToDismissResult> linkedStudents = ActionBLL.GetStudentsToDismiss(hdnSelectedSchoolId.Value, string.Empty, hdnSelectedParentId.Value);

                    if (linkedStudents != null && linkedStudents.Count > 0)
                    {

                        chkLstStudents.DataSource = linkedStudents;
                        chkLstStudents.DataTextField = "Name";
                        chkLstStudents.DataValueField = "ID";
                        chkLstStudents.DataBind();

                    }
                    else
                    {
                        lblSelectStudent.Visible = chkLstStudents.Visible = false;
                        lblNoStudent.Visible = true;
                    }
                    ShowPanel(panelSelectStudent);
                }
            }
            catch (Exception ex)
            {
                ErrorBLL.Insert(ex, "btnNextParentIdPicture_Click > userid: " + SessionKeys.User.UserId);
            }
        }

        protected void btnBackSelectStudent_Click(object sender, EventArgs e)
        {
            ShowPanel(panelTakeParentIdPicture);
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "TakeParentIdPhoto();", true);
        }

        protected void btnDone_Click(object sender, EventArgs e)
        {
            try
            {
                string parentCount = hdnParentCount.Value;
                //string imgName = hdnImgName.Value;
                //if(!string.IsNullOrEmpty(imgName))
                //    imgName = imgName + ".jpg";

                string imgName = string.Empty;


                string dismissedBy = SessionKeys.User.LastName + ", " + SessionKeys.User.FirstName;
                if (parentCount == "0" || !string.IsNullOrEmpty(hdnSelectedStudentId.Value))
                {
                    imgName = SaveImage();
                    ActionBLL.DismissStudent(hdnSelectedStudentId.Value, hdnSelectedSchoolId.Value, string.Empty, string.Empty, imgName, dismissedBy);
                    ShowPanel(panelDismissToSameParent);
                }
                else
                {
                    string parentId = hdnSelectedParentId.Value;
                    List<string> selectedValues = chkLstStudents.Items.Cast<ListItem>()
                                                     .Where(li => li.Selected)
                                                     .Select(li => li.Value)
                                                     .ToList();
                    if (selectedValues != null && selectedValues.Count > 0)
                    {
                        imgName = SaveImage();
                        foreach (string studentId in selectedValues)
                        {
                            ActionBLL.DismissStudent(studentId, hdnSelectedSchoolId.Value, parentId, txtParentName.Text, imgName, dismissedBy);
                        }
                    }
                    Response.Redirect("dismissal.aspx", true);
                }

            }
            catch (Exception ex)
            {
                ErrorBLL.Insert(ex, "btnDone_Click > userid: " + SessionKeys.User.UserId);
            }
        }

        private string SaveImage()
        {
            string imgName = string.Empty;
            if (string.IsNullOrEmpty(hdnPhotoName.Value))
            {
                imgName = Guid.NewGuid().ToString();
                hdnPhotoName.Value = imgName;
                String dirPath = System.Configuration.ConfigurationManager.AppSettings["SEMImagesPath"];
                string parentPhotoBytes = hdnParentPhoto.Value;
                if (!string.IsNullOrEmpty(parentPhotoBytes))
                {

                    byte[] imgByteArray = Convert.FromBase64String(parentPhotoBytes);
                    File.WriteAllBytes(Path.Combine(dirPath, imgName + ".jpg"), imgByteArray);
                }

                string parentIdPhotoBytes = hdnParentIdPhoto.Value;
                if (!string.IsNullOrEmpty(parentIdPhotoBytes))
                {
                    byte[] imgByteArray = Convert.FromBase64String(parentIdPhotoBytes);
                    File.WriteAllBytes(Path.Combine(dirPath, imgName + "_id.jpg"), imgByteArray);
                }
            }
            else
            {
                imgName = hdnPhotoName.Value;
            }
            return imgName;
        }

        protected void btnDismissToSameAdult_Click(object sender, EventArgs e)
        {
            ShowPanel(panelStudentsPicklist);
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "LoadStudents();", true);
        }

        protected void btnNewDismissal_Click(object sender, EventArgs e)
        {
            Response.Redirect("dismissal.aspx", true);
        }
    }
}