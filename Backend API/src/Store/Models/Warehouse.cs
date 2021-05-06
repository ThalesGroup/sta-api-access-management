/*
 * Simple Store API
 *
 * A simple store API
 *
 * OpenAPI spec version: 1.0.0
 * 
 * Generated by: https://github.com/swagger-api/swagger-codegen.git
 */
using System;
using System.Text;
using System.Runtime.Serialization;

// ReSharper disable NonReadonlyMemberInGetHashCode

namespace Store.Models
{ 
    /// <summary>
    /// The warehouse 
    /// </summary>
    [DataContract]
    public class Warehouse : WarehouseInfo, IEquatable<Warehouse>
    { 
        /// <summary>
        /// Warehouse Description
        /// </summary>
        /// <value>Warehouse Description</value>
        [DataMember(Name="description")]
        public string Description { get; set; }

        /// <summary>
        /// Returns the string presentation of the object
        /// </summary>
        /// <returns>String presentation of the object</returns>
        public override string ToString()
        {
            var sb = new StringBuilder();
            sb.Append("class WarehouseData {\n");
            sb.Append("  Description: ").Append(Description).Append("\n");
            sb.Append("}\n");
            return sb.ToString();
        }

        /// <summary>
        /// Returns true if objects are equal
        /// </summary>
        /// <param name="obj">Object to be compared</param>
        /// <returns>Boolean</returns>
        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            return obj.GetType() == GetType() && Equals((Warehouse)obj);
        }

        /// <summary>
        /// Returns true if WarehouseData instances are equal
        /// </summary>
        /// <param name="other">Instance of WarehouseData to be compared</param>
        /// <returns>Boolean</returns>
        public bool Equals(Warehouse other)
        {
            if (ReferenceEquals(null, other)) return false;
            if (ReferenceEquals(this, other)) return true;

            return 
                (
                    Description == other.Description ||
                    Description != null &&
                    Description.Equals(other.Description)
                );
        }

        /// <summary>
        /// Gets the hash code
        /// </summary>
        /// <returns>Hash code</returns>
        public override int GetHashCode()
        {
            unchecked // Overflow is fine, just wrap
            {
                var hashCode = 41;
                // Suitable nullity checks etc, of course :)
                    if (Description != null)
                    hashCode = hashCode * 59 + Description.GetHashCode();
                return hashCode;
            }
        }

        #region Operators
        #pragma warning disable 1591

        public static bool operator ==(Warehouse left, Warehouse right)
        {
            return Equals(left, right);
        }

        public static bool operator !=(Warehouse left, Warehouse right)
        {
            return !Equals(left, right);
        }

        #pragma warning restore 1591
        #endregion Operators
    }
}
