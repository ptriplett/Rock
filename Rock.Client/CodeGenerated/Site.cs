//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by the Rock.CodeGeneration project
//     Changes to this file will be lost when the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------
// <copyright>
// Copyright by the Spark Development Network
//
// Licensed under the Rock Community License (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.rockrms.com/license
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>
//
using System;
using System.Collections.Generic;


namespace Rock.Client
{
    /// <summary>
    /// Base client model for Site that only includes the non-virtual fields. Use this for PUT/POSTs
    /// </summary>
    public partial class SiteEntity
    {
        /// <summary />
        public int Id { get; set; }

        /// <summary />
        public string AllowedFrameDomains { get; set; }

        /// <summary />
        public bool AllowIndexing { get; set; } = true;

        /// <summary />
        public int? ChangePasswordPageId { get; set; }

        /// <summary />
        public int? ChangePasswordPageRouteId { get; set; }

        /// <summary />
        public int? CommunicationPageId { get; set; }

        /// <summary />
        public int? CommunicationPageRouteId { get; set; }

        /// <summary />
        public int? DefaultPageId { get; set; }

        /// <summary />
        public int? DefaultPageRouteId { get; set; }

        /// <summary />
        public string Description { get; set; }

        /// <summary />
        public bool EnabledForShortening { get; set; } = true;

        /// <summary />
        public bool EnableMobileRedirect { get; set; }

        /// <summary />
        public bool EnablePageViews { get; set; } = true;

        /// <summary />
        public string ErrorPage { get; set; }

        /// <summary />
        public string ExternalUrl { get; set; }

        /// <summary />
        public int? FavIconBinaryFileId { get; set; }

        /// <summary />
        public Guid? ForeignGuid { get; set; }

        /// <summary />
        public string ForeignKey { get; set; }

        /// <summary />
        public string GoogleAnalyticsCode { get; set; }

        /// <summary />
        // Made Obsolete in Rock "1.8"
        [Obsolete( "Moved to Theme", false )]
        public Rock.Client.Enums.IconCssWeight IconCssWeight { get; set; }

        /// <summary />
        public string IndexStartingLocation { get; set; }

        /// <summary />
        public bool IsIndexEnabled { get; set; }

        /// <summary />
        public bool IsSystem { get; set; }

        /// <summary />
        public int? LoginPageId { get; set; }

        /// <summary />
        public int? LoginPageRouteId { get; set; }

        /// <summary />
        public int? MobilePageId { get; set; }

        /// <summary>
        /// If the ModifiedByPersonAliasId is being set manually and should not be overwritten with current user when saved, set this value to true
        /// </summary>
        public bool ModifiedAuditValuesAlreadyUpdated { get; set; }

        /// <summary />
        public string Name { get; set; }

        /// <summary />
        public string PageHeaderContent { get; set; }

        /// <summary />
        public int? PageNotFoundPageId { get; set; }

        /// <summary />
        public int? PageNotFoundPageRouteId { get; set; }

        /// <summary />
        public bool RedirectTablets { get; set; }

        /// <summary />
        public int? RegistrationPageId { get; set; }

        /// <summary />
        public int? RegistrationPageRouteId { get; set; }

        /// <summary />
        public bool RequiresEncryption { get; set; }

        /// <summary />
        public int? SiteLogoBinaryFileId { get; set; }

        /// <summary />
        public string Theme { get; set; }

        /// <summary>
        /// Leave this as NULL to let Rock set this
        /// </summary>
        public DateTime? CreatedDateTime { get; set; }

        /// <summary>
        /// This does not need to be set or changed. Rock will always set this to the current date/time when saved to the database.
        /// </summary>
        public DateTime? ModifiedDateTime { get; set; }

        /// <summary>
        /// Leave this as NULL to let Rock set this
        /// </summary>
        public int? CreatedByPersonAliasId { get; set; }

        /// <summary>
        /// If you need to set this manually, set ModifiedAuditValuesAlreadyUpdated=True to prevent Rock from setting it
        /// </summary>
        public int? ModifiedByPersonAliasId { get; set; }

        /// <summary />
        public Guid Guid { get; set; }

        /// <summary />
        public int? ForeignId { get; set; }

        /// <summary>
        /// Copies the base properties from a source Site object
        /// </summary>
        /// <param name="source">The source.</param>
        public void CopyPropertiesFrom( Site source )
        {
            this.Id = source.Id;
            this.AllowedFrameDomains = source.AllowedFrameDomains;
            this.AllowIndexing = source.AllowIndexing;
            this.ChangePasswordPageId = source.ChangePasswordPageId;
            this.ChangePasswordPageRouteId = source.ChangePasswordPageRouteId;
            this.CommunicationPageId = source.CommunicationPageId;
            this.CommunicationPageRouteId = source.CommunicationPageRouteId;
            this.DefaultPageId = source.DefaultPageId;
            this.DefaultPageRouteId = source.DefaultPageRouteId;
            this.Description = source.Description;
            this.EnabledForShortening = source.EnabledForShortening;
            this.EnableMobileRedirect = source.EnableMobileRedirect;
            this.EnablePageViews = source.EnablePageViews;
            this.ErrorPage = source.ErrorPage;
            this.ExternalUrl = source.ExternalUrl;
            this.FavIconBinaryFileId = source.FavIconBinaryFileId;
            this.ForeignGuid = source.ForeignGuid;
            this.ForeignKey = source.ForeignKey;
            this.GoogleAnalyticsCode = source.GoogleAnalyticsCode;
            #pragma warning disable 612, 618
            this.IconCssWeight = source.IconCssWeight;
            #pragma warning restore 612, 618
            this.IndexStartingLocation = source.IndexStartingLocation;
            this.IsIndexEnabled = source.IsIndexEnabled;
            this.IsSystem = source.IsSystem;
            this.LoginPageId = source.LoginPageId;
            this.LoginPageRouteId = source.LoginPageRouteId;
            this.MobilePageId = source.MobilePageId;
            this.ModifiedAuditValuesAlreadyUpdated = source.ModifiedAuditValuesAlreadyUpdated;
            this.Name = source.Name;
            this.PageHeaderContent = source.PageHeaderContent;
            this.PageNotFoundPageId = source.PageNotFoundPageId;
            this.PageNotFoundPageRouteId = source.PageNotFoundPageRouteId;
            this.RedirectTablets = source.RedirectTablets;
            this.RegistrationPageId = source.RegistrationPageId;
            this.RegistrationPageRouteId = source.RegistrationPageRouteId;
            this.RequiresEncryption = source.RequiresEncryption;
            this.SiteLogoBinaryFileId = source.SiteLogoBinaryFileId;
            this.Theme = source.Theme;
            this.CreatedDateTime = source.CreatedDateTime;
            this.ModifiedDateTime = source.ModifiedDateTime;
            this.CreatedByPersonAliasId = source.CreatedByPersonAliasId;
            this.ModifiedByPersonAliasId = source.ModifiedByPersonAliasId;
            this.Guid = source.Guid;
            this.ForeignId = source.ForeignId;

        }
    }

    /// <summary>
    /// Client model for Site that includes all the fields that are available for GETs. Use this for GETs (use SiteEntity for POST/PUTs)
    /// </summary>
    public partial class Site : SiteEntity
    {
        /// <summary />
        public ICollection<Block> Blocks { get; set; }

        /// <summary />
        public PageRoute ChangePasswordPageRoute { get; set; }

        /// <summary />
        public Page CommunicationPage { get; set; }

        /// <summary />
        public PageRoute CommunicationPageRoute { get; set; }

        /// <summary />
        public Page DefaultPage { get; set; }

        /// <summary />
        public PageRoute DefaultPageRoute { get; set; }

        /// <summary />
        public ICollection<Layout> Layouts { get; set; }

        /// <summary />
        public Page LoginPage { get; set; }

        /// <summary />
        public PageRoute LoginPageRoute { get; set; }

        /// <summary />
        public Page MobilePage { get; set; }

        /// <summary />
        public Page PageNotFoundPage { get; set; }

        /// <summary />
        public PageRoute PageNotFoundPageRoute { get; set; }

        /// <summary />
        public Page RegistrationPage { get; set; }

        /// <summary />
        public PageRoute RegistrationPageRoute { get; set; }

        /// <summary />
        public ICollection<SiteDomain> SiteDomains { get; set; }

        /// <summary>
        /// NOTE: Attributes are only populated when ?loadAttributes is specified. Options for loadAttributes are true, false, 'simple', 'expanded' 
        /// </summary>
        public Dictionary<string, Rock.Client.Attribute> Attributes { get; set; }

        /// <summary>
        /// NOTE: AttributeValues are only populated when ?loadAttributes is specified. Options for loadAttributes are true, false, 'simple', 'expanded' 
        /// </summary>
        public Dictionary<string, Rock.Client.AttributeValue> AttributeValues { get; set; }
    }
}
