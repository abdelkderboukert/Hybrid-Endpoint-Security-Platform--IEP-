from rest_framework import permissions

class IsLicenseActive(permissions.BasePermission):
    """
    Custom permission to only allow users with an active license.
    """
    message = 'Your account does not have an active license. Please activate your license key to proceed.'

    def has_permission(self, request, view):
        # The permission is granted if the user is authenticated
        # and their 'license' field is not None.
        return request.user.is_authenticated and request.user.license is not None