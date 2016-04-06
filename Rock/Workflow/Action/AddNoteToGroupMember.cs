﻿// <copyright>
// Copyright 2013 by the Spark Development Network
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
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
using System.ComponentModel;
using System.ComponentModel.Composition;
using System.Linq;

using Rock;
using Rock.Attribute;
using Rock.Data;
using Rock.Model;
using Rock.Web.Cache;

namespace Rock.Workflow.Action
{
    /// <summary>
    /// Sets an group member's note.
    /// </summary>
    [ActionCategory( "Group Update" )]
    [Description( "Adds a note to a group member." )]
    [Export( typeof( ActionComponent ) )]
    [ExportMetadata( "ComponentName", "Add Note To Group Member" )]

    [WorkflowAttribute( "Person", "Workflow attribute that contains the person to update in the group.", true, "", "", 0, null,
        new string[] { "Rock.Field.Types.PersonFieldType" } )]

    [WorkflowAttribute( "Group", "Workflow Attribute that contains the group the person is in.", true, "", "", 1, null,
        new string[] { "Rock.Field.Types.GroupFieldType" } )]

    [NoteTypeField( "Note Type", "The type of note to add to the group member.", false, "Rock.Model.GroupMember", order: 2 )]

    [WorkflowTextOrAttribute( "Caption", "Attribute Value", "Text or workflow attribute that contains the caption to set the group member note to. <span class='tip tip-lava'></span>", true, "", "", 3, "Caption",
        new string[] { "Rock.Field.Types.TextFieldType" } )]

    [WorkflowTextOrAttribute( "Note", "Attribute Value", "Text or workflow attribute that contains the text to set the group member note to. <span class='tip tip-lava'></span>", true, "", "", 4, "Note",
        new string[] { "Rock.Field.Types.MemoFieldType", "Rock.Field.Types.TextFieldType" }, 3 )]

    [WorkflowTextOrAttribute( "Is Alert", "Attribute Value", "Boolean (must enter True/False) or workflow attribute that contains whether the note should be an alert.", false, "False", "", 5, "IsAlert",
        new string[] { "Rock.Field.Types.BooleanFieldType" } )]

    
    public class AddNoteToGroupMember : ActionComponent
    {
        /// <summary>
        /// Executes the specified workflow.
        /// </summary>
        /// <param name="rockContext">The rock context.</param>
        /// <param name="action">The action.</param>
        /// <param name="entity">The entity.</param>
        /// <param name="errorMessages">The error messages.</param>
        /// <returns></returns>
        public override bool Execute( RockContext rockContext, WorkflowAction action, Object entity, out List<string> errorMessages )
        {
            errorMessages = new List<string>();

            Guid? groupGuid = null;
            Person person = null;
            Group group = null;
            string noteValue = string.Empty;
            string captionValue = string.Empty;
            bool isAlert = false;

            // get the group attribute
            Guid groupAttributeGuid = GetAttributeValue( action, "Group" ).AsGuid();

            if ( !groupAttributeGuid.IsEmpty() )
            {
                groupGuid = action.GetWorklowAttributeValue( groupAttributeGuid ).AsGuidOrNull();

                if ( groupGuid.HasValue )
                {
                    group = new GroupService( rockContext ).Get( groupGuid.Value );

                    if ( group == null )
                    {
                        errorMessages.Add( "The group provided does not exist." );
                    }
                }
                else 
                {
                    errorMessages.Add( "Invalid group provided." );
                }
            }

            // get person alias guid
            Guid personAliasGuid = Guid.Empty;
            string personAttribute = GetAttributeValue( action, "Person" );

            Guid guid = personAttribute.AsGuid();
            if ( !guid.IsEmpty() )
            {
                var attribute = AttributeCache.Read( guid, rockContext );
                if ( attribute != null )
                {
                    string value = action.GetWorklowAttributeValue( guid );
                    personAliasGuid = value.AsGuid();
                }

                if ( personAliasGuid != Guid.Empty )
                {
                    person = new PersonAliasService( rockContext ).Queryable()
                                    .Where( p => p.Guid.Equals( personAliasGuid ) )
                                    .Select( p => p.Person )
                                    .FirstOrDefault();
                }
                else
                {
                    errorMessages.Add( "The person could not be found!" );
                }
            }

            // get caption
            captionValue = GetAttributeValue( action, "Caption" );
            guid = captionValue.AsGuid();
            if ( guid.IsEmpty() )
            {
                captionValue = captionValue.ResolveMergeFields( GetMergeFields( action ) );
            }
            else
            {
                var workflowAttributeValue = action.GetWorklowAttributeValue( guid );

                if ( workflowAttributeValue != null )
                {
                    captionValue = workflowAttributeValue;
                }
            }

            // get group member note
            noteValue = GetAttributeValue( action, "Note" );
            guid = noteValue.AsGuid();
            if ( guid.IsEmpty() )
            {
                noteValue = noteValue.ResolveMergeFields( GetMergeFields( action ) );
            }
            else
            {
                var workflowAttributeValue = action.GetWorklowAttributeValue( guid );

                if ( workflowAttributeValue != null )
                {
                    noteValue = workflowAttributeValue;
                }
            }

            // get alert type
            string isAlertString = GetAttributeValue( action, "IsAlert" );
            guid = isAlertString.AsGuid();
            if ( guid.IsEmpty() )
            {
                isAlert = isAlertString.AsBoolean();
            }
            else
            {
                var workflowAttributeValue = action.GetWorklowAttributeValue( guid );

                if ( workflowAttributeValue != null )
                {
                    isAlert = workflowAttributeValue.AsBoolean();
                }
            }

            // get note type
            NoteTypeCache noteType = null;
            Guid noteTypeGuid = GetAttributeValue( action, "NoteType" ).AsGuid();
            
            if ( !noteTypeGuid.IsEmpty() )
            {
                noteType = NoteTypeCache.Read( noteTypeGuid, rockContext );

                if (noteType == null )
                {
                    errorMessages.Add( "The note type provided does not exist." );
                }
            } 
            else
            {
                errorMessages.Add( "Invalid note type provided." );
            }

            
            // set note
            if ( group != null && person != null && noteType != null )
            {
                var groupMembers = new GroupMemberService( rockContext ).Queryable()
                                .Where( m => m.Group.Guid == groupGuid && m.PersonId == person.Id ).ToList();

                if ( groupMembers.Count() > 0 )
                {
                    foreach ( var groupMember in groupMembers )
                    {
                        NoteService noteservice = new NoteService( rockContext );
                        Note note = new Note();
                        noteservice.Add( note );

                        note.NoteTypeId = noteType.Id;
                        note.Text = noteValue;
                        note.IsAlert = isAlert;
                        note.Caption = captionValue;
                        note.EntityId = groupMember.Id;

                        rockContext.SaveChanges();
                    }
                }
                else
                {
                    errorMessages.Add( string.Format("{0} is not a member of the group {1}.", person.FullName, group.Name ));
                }
            }

            errorMessages.ForEach( m => action.AddLogEntry( m, true ) );

            return true;
        }
    }
}